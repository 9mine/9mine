-- given the number of files in directory
-- calculates optimal platform size
function plt.get_size(dir_size)
    local size = math.ceil(math.sqrt((dir_size / 15) * 100))
    local plt_size = size < 3 and 3 or size
    return plt_size
end
