-- https://en.wikipedia.org/wiki/Graph_(abstract_data_type)
-- https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)

-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
-- local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
-- local TableUtils = Mod:find({"Table", "Utils"})

local Graph = {}
-- Graph.__index = Graph

-- Graph.Representations = {
--     ["AdjacencyList"] = "1",
--     ["AdjacencyMatrix"] = "2",
--     ["IncidenceMatrix"] = "3",
-- }

-- Graph.EdgeType = {
--     ["Undirected"] = "1",
--     ["Directed "] = "2",
--     ["Mixed"] = "3",
-- }

-- -- DAG. Edge goes from edge[1] to edge[2]
-- -- UAG must add new edges
-- function Graph.new(nodes, edges, kwargs)
--     kwargs = kwargs or {}
--     local self = {
--         edges = edges, -- Edge always
--         nodes = nodes,
--         representations = {}
--     }
--     setmetatable(self, Graph)
--     if kwargs.graphType == Graph.EdgeType.Undirected then
--         self:add
--     end
--     return self
-- end

-- function Graph:createAdjacencyList()
--     self.representations[Graph.Representations.AdjacencyList] = true

--     self.adjacencyList = {}
--     for _, edge in ipairs(self.edges) do
--         self.adjacencyList[edge[1]] = self.adjacencyList[edge[1]] or {}
--         table.insert(self.adjacencyList[edge[1]], edge[2])
--     end
-- end

-- function Graph:createAdjacencyMatrix()
--     self.adjacencyMatrix = {}
--     for _, edge in ipairs(self.edges) do
--         self.adjacencyMatrix[edge[0]][edge[1]] = true
--         self.adjacencyMatrix[edge[1]][edge[0]] = true
--     end
-- end

-- function Graph:adjacent(node1, node2)
--     error("Implement")
-- end

-- function Graph:neighbors(node1)
--     error("Implement")
-- end

-- -- Depends on representation
-- function Graph:addNodes(nodes)

-- end

-- function Graph:removeNodes(nodes)

-- end

-- function Graph:addEdges(edges)

-- end

-- function Graph:removeEdges(edges)

-- end

-- function Graph:setNodeValue(node, value)

-- end

-- function Graph:getNodeValue(node)

-- end

-- function Graph:setEdgeValue(node, value)

-- end

-- function Graph:getEdgeValue(node)

-- end

-- function Graph:clearAdjacencyList()
--     self.adjacencyList = nil
-- end

-- function Graph:clearAdjacencyMatrix()
--     self.adjacencyMatrix = nil
-- end


-- function Graph:clearEdgeList()
--     self.edges = nil
-- end

-- function Graph:Destroy()
--     Graph:clearAdjacencyList()
--     Graph:clearAdjacencyMatrix()
--     Graph:clearEdgeList()
-- end

return Graph