local M = {}

function M.start()

    -- start a socket that we can listen for the result on
    local socketname = vim.fn.tempname()
    vim.fn.serverstart(socketname)

    -- generate the nnn command with the right parameters
    local currentLocation = vim.fn.expand('%:p:h')
    local filepickercommand = 'nnn -p - ' .. currentLocation

    -- use nvim --server to "callback" over rpc the result of "filepickercommand"
    local callbackcommand = string.format(
                                [[%s | nvim --server %s --remote $(filepickercommand) ]],
                                socketname, filepickercommand)

    -- open up the callbackcommand (which already contains the filepickercommand) in a new terminal buffer
    vim.cmd('term ' .. callbackcommand)
    -- when entering the terminal, automatically enter in insert mode
    vim.cmd('startinsert')

    -- lets grab the buffer number of the terminal buffer we just made
    local termbuffnumber = vim.api.nvim_get_current_buf()

    -- upon closing the terminal (aka, when nnn and the callback process exits), delete the buffer
    vim.api.nvim_create_autocmd({"TermClose"}, {
        buffer = termbuffnumber,
        command = "bd " .. termbuffnumber
    })

end

return M
