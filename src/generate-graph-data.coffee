###
Generate preformatted data of commits graph.
###


generateGraphData = (commits) ->
  ###
  Generate graph data.

  :param commits: a list of commit, which should have
    `sha`, `parents` properties.
  :returns: data nodes, a json list of
    [
      sha,
      [offset, branch], //dot
      [
      [from, to, branch],  // route 1
      [from, to, branch],  // route 2
      [from, to, branch],
      ]  // routes
    ],  // node
  ###

  nodes = []
  branchIndex = [0]
  reserve = []
  branches = {}

  getBranch = (sha) ->
    unless branches[sha]?
      branches[sha] = branchIndex[0]
      reserve.push(branchIndex[0])
      branchIndex[0]++
    branches[sha]

  for commit in commits
    branch = getBranch(commit.sha)
    numParents = commit.parents.length
    offset = reserve.indexOf(branch)
    routes = []

    if numParents is 1
      if branches[commit.parents[0]]?
        # create branch
        for b, i in reserve[offset + 1..]
          routes.push [i + offset + 1, i + offset + 1 - 1, b]
        for b, i in reserve[...offset]
          routes.push [i, i, b]
        remove(reserve, branch)
        routes.push([offset, reserve.indexOf(branches[commit.parents[0]]), branch])
      else
        # straight
        for b, i in reserve
          routes.push [i, i, b]
        branches[commit.parents[0]] = branch
    else if numParents is 2
      # merge branch
      branches[commit.parents[0]] = branch
      for b, i in reserve
        routes.push [i, i, b]
      otherBranch = getBranch(commit.parents[1])
      routes.push([offset, reserve.indexOf(otherBranch), otherBranch])

    node = Node(commit.sha, offset, branch, routes)
    nodes.push(node)

  nodes

remove = (list, item) ->
  list.splice(list.indexOf(item), 1)
  list

Node = (sha, offset, branch, routes) ->
  [sha, [offset, branch], routes]

module.exports = generateGraphData
