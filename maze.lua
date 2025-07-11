-- Global variables for DSU and grid state
-- In Lua, tables are used for arrays and dictionaries.
maze_rows = 0
maze_cols = 0
parent = {} -- DSU parent table (1-indexed)
size = {}   -- DSU size table (1-indexed)
grid = {}   -- Maze grid representation (nested tables, 1-indexed)

-- Function to get a 1D index from 2D cell coordinates (0-indexed r, c)
function _get_cell_index(row, col)
    return row * maze_cols + col
end

-- Find operation for Disjoint Set Union (DSU) - ITERATIVE VERSION
function find(i)
    local idx_1_based = i + 1

    local current = idx_1_based
    while parent[current] ~= current do
        current = parent[current]
    end
    return current
end

-- Union operation for Disjoint Set Union (DSU)
-- i and j are 0-based cell indices.
-- Returns true if a union occurred, false otherwise.
function union(i, j)
    local root_i = find(i)
    local root_j = find(j)

    if root_i ~= root_j then
        -- Union by size: attach smaller tree under root of larger tree
        if size[root_i] < size[root_j] then
            parent[root_i] = root_j
            size[root_j] = size[root_j] + size[root_i]
        else
            parent[root_j] = root_i
            size[root_i] = size[root_i] + size[root_j]
        end
        return true -- Union successful
    end
    return false -- Already in the same set
end

-- Shuffles a table (array) in-place using Fisher-Yates algorithm.
function shuffle(t)
    math.randomseed(os.epoch("utc"))
    local n = #t
    while n > 1 do
        local k = math.random(n) -- Pick a random element from 1 to n
        -- Swap t[n] and t[k]
        local temp = t[n]
        t[n] = t[k]
        t[k] = temp
        n = n - 1
    end
end

-- Initializes the maze grid with all walls present and sets up DSU.
function initialize_maze_grid(rows, cols)
    maze_rows = rows
    maze_cols = cols

    -- Initialize DSU components (1-based indexing for Lua tables)
    local n_elements = rows * cols
    for i = 1, n_elements do
        parent[i] = i
        size[i] = 1
    end

    -- Initialize the grid with '#' (walls)
    -- Grid dimensions for printing: (2 * _maze_rows + 1) x (2 * _maze_cols + 1)
    -- Lua tables are 1-indexed, so we iterate from 1 up to the max dimension.
    for r_idx = 1, (2 * maze_rows + 1) do
        grid[r_idx] = {} -- Create inner table for the row
        for c_idx = 1, (2 * maze_cols + 1) do
            grid[r_idx][c_idx] = '#'
        end
    end

    -- Mark cells as empty space ' '
    -- r and c here are 0-indexed for conceptual mapping to Python logic
    for r = 0, maze_rows - 1 do
        for c = 0, maze_cols - 1 do
            -- Convert 0-indexed cell (r, c) to 1-indexed grid coordinates
            grid[2 * r + 1 + 1][2 * c + 1 + 1] = ' '
        end
    end
end

-- Generates the maze using Randomized Kruskal's Algorithm.
-- Assumes initialize_maze_grid has been called.
function generate_maze()
    local walls = {} -- Lua table to store walls

    -- Collect all possible horizontal walls
    -- r and c here are 0-indexed for conceptual mapping to Python logic
    for r = 0, maze_rows - 1 do
        for c = 0, maze_cols - 2 do -- c up to cols - 2 for wall between c and c+1
            -- Wall between (r, c) and (r, c+1)
            table.insert(walls, {{r, c}, {r, c + 1}})
        end
    end

    -- Collect all possible vertical walls
    -- r and c here are 0-indexed for conceptual mapping to Python logic
    for r = 0, maze_rows - 2 do -- r up to rows - 2 for wall between r and r+1
        for c = 0, maze_cols - 1 do
            -- Wall between (r, c) and (r+1, c)
            table.insert(walls, {{r, c}, {r + 1, c}})
        end
    end

    -- Seed the random number generator for shuffling
    math.randomseed(os.time())
    shuffle(walls) -- Randomize the order of walls

    -- Iterate through shuffled walls and remove them if they connect
    -- two previously unconnected cells
    for i = 1, #walls do
        local wall = walls[i]
        local cell1 = wall[1] -- {r1, c1}
        local cell2 = wall[2] -- {r2, c2}

        local r1, c1 = cell1[1], cell1[2]
        local r2, c2 = cell2[1], cell2[2]

        local idx1 = _get_cell_index(r1, c1)
        local idx2 = _get_cell_index(r2, c2)

        -- Use the integrated union function
        if union(idx1, idx2) then
            -- If union was successful, it means the cells were in different sets.
            -- Remove the wall between them.
            -- Determine the grid coordinates of the wall to remove.
            if r1 == r2 then -- Horizontal wall
                -- Wall is at grid[2*r1+1][2*c1+2]
                -- Convert 0-indexed cell coords to 1-indexed grid coords
                grid[2 * r1 + 1 + 1][2 * c1 + 2 + 1] = ' '
            elseif c1 == c2 then -- Vertical wall
                -- Wall is at grid[2*r1+2][2*c1+1]
                -- Convert 0-indexed cell coords to 1-indexed grid coords
                grid[2 * r1 + 2 + 1][2 * c1 + 1 + 1] = ' '
            end
        end
    end
end

-- Prints the generated maze to the console.
-- Assumes a maze has been generated and _grid is populated.
function print_maze()
    for r_idx = 1, #grid do
        local row_str = ""
        for c_idx = 1, #grid[r_idx] do
            row_str = row_str .. grid[r_idx][c_idx]
        end
        print(row_str)
    end
end

-- --- Example Usage ---
-- This block will run when the script is executed in ComputerCraft.
-- You can save this file as, for example, 'maze.lua' on your ComputerCraft computer
-- and run it using 'lua maze.lua'.

print("\n--- Another Maze (5x5) ---")
-- Re-initialize for a new maze
initialize_maze_grid(5, 5)
generate_maze()
print_maze()
