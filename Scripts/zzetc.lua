function _ExtractNonEditDifficultyBiases()
    local cur_song = GAMESTATE:GetCurrentSong()
    if cur_song == nil then return { } end

    local s = GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber())
    local steps = cur_song:GetStepsByStepsType(s:GetStepsType())

    local biases = { }

    for _,step in pairs(steps) do
        -- skip edits
        if step:GetDifficulty() ~= DIFFICULTY_EDIT then
            biases[step:GetDifficulty()] = ExtractDifficultyBias(step:GetDescription())
        end
    end

    return biases
end

function ExtractDifficultyBias(step_description)
    if step_description == nil then return end

    local bias = nil;

    _, _, bias = string.find(step_description, '^(%d+[+-])')

    return bias
end

function _ApplyDifficultyBiasToEdit(row)
    if row == nil then return end

    local meter       = row:GetChild('Meter')
    local description = row:GetChild('EditDescription')

    -- not on ScreenSelectMusic[Course] or iterating a row not in this style?
    if description == nil or meter == nil then return end

    local desc_text = description:GetText()

    -- blank values on non-edits - can't apply
    if desc_text == '' then return end

    local bias = ExtractDifficultyBias(desc_text)

    if bias == nil then return end

    meter:settext(bias)
end

function _ApplyDifficultyBiasToNonEdit(row)
    local diff_native = _G['_sandbox_diff_lookup'][string.lower(row:GetChild('Difficulty'):GetText())]

    if row:GetChild('EditDescription'):GetText() == '' and _G['_sandbox_diff_biases'][diff_native] ~= nil then
        row:GetChild('Meter'):settext(_G['_sandbox_diff_biases'][diff_native])
    end
end

function ApplyDifficultyBias()
    local diff_list = SCREENMAN:GetTopScreen():GetChild('DifficultyList')
    if diff_list == nil then return end

    local cur_song = GAMESTATE:GetCurrentSong()
    if cur_song == nil then return { } end

    -- do regular charts
    _G['_sandbox_diff_biases'] = _ExtractNonEditDifficultyBiases()
    diff_list:playcommand('_ApplyDifficultyBiasToNonEdit')

    -- do edits too
    diff_list:playcommand('_ApplyDifficultyBiasToEdit')
end

-- wrap this so the command line interpreter doesn't freak out
if THEME ~= nil then
    local __sandbox_diff_lookup = {
        [ string.lower(THEME:GetMetric('Difficulty', 'Beginner')) ]  = DIFFICULTY_BEGINNER,
        [ string.lower(THEME:GetMetric('Difficulty', 'Easy')) ]      = DIFFICULTY_EASY,
        [ string.lower(THEME:GetMetric('Difficulty', 'Medium')) ]    = DIFFICULTY_MEDIUM,
        [ string.lower(THEME:GetMetric('Difficulty', 'Hard')) ]      = DIFFICULTY_HARD,
        [ string.lower(THEME:GetMetric('Difficulty', 'Challenge')) ] = DIFFICULTY_CHALLENGE,
        [ string.lower(THEME:GetMetric('Difficulty', 'Edit')) ]      = DIFFICULTY_EDIT,
    }

    _G['_sandbox_diff_lookup'] = __sandbox_diff_lookup
    _G['_sandbox_diff_biases'] = { }
end
