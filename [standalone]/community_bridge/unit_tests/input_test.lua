-- Test QB Format Input
RegisterCommand('input_test_qb', function()
    local qbFormatData = {
        inputs = {
            {
                text = "Player Name",
                name = "playername",
                type = "text",
                isRequired = true,
                default = "John Doe"
            },
            {
                text = "Player ID",
                name = "playerid",
                type = "number",
                isRequired = true
            },
            {
                text = "Password",
                name = "password",
                type = "password",
                isRequired = false
            },
            {
                text = "Vehicle Type",
                name = "vehicle",
                type = "select",
                isRequired = true,
                options = {
                    {value = "car", text = "Car"},
                    {value = "bike", text = "Motorcycle"},
                    {value = "truck", text = "Truck"}
                }
            },
            {
                text = "Enable Notifications",
                name = "notifications",
                type = "checkbox",
                isRequired = false,
                options = {
                    {value = "email", text = "Email", checked = true},
                    {value = "sms", text = "SMS", checked = false}
                }
            }
        }
    }
    
    local result = Input.Open("QB Format Test", qbFormatData, true, "Submit")
    if result then
        print("QB Format Result:")
        for k, v in pairs(result) do
            print(k .. ": " .. tostring(v))
        end
    else
        print("QB Format: User cancelled or no input")
    end
end, false)

-- Test Ox Format Input
RegisterCommand('input_test_ox', function()
    local oxFormatData = {
        {
            type = "input",
            label = "Character Name",
            name = "charname",
            required = true,
            default = "Jane Smith"
        },
        {
            type = "number",
            label = "Age",
            name = "age",
            required = true,
            min = 18,
            max = 100
        },
        {
            type = "select",
            label = "Job Category",
            name = "jobcat",
            required = true,
            options = {
                {value = "civ", label = "Civilian"},
                {value = "leo", label = "Law Enforcement"},
                {value = "ems", label = "Emergency Medical"}
            }
        },
        {
            type = "checkbox",
            label = "Has License",
            name = "license",
            required = false
        },
        {
            type = "color",
            label = "Favorite Color",
            name = "color",
            default = "#ff0000"
        },
        {
            type = "date",
            label = "Birth Date",
            name = "birthdate",
            format = "DD/MM/YYYY"
        }
    }
    
    local result = Input.Open("Ox Format Test", oxFormatData, false)
    if result then
        print("Ox Format Result:")
        for k, v in pairs(result) do
            print(k .. ": " .. tostring(v))
        end
    else
        print("Ox Format: User cancelled or no input")
    end
end, false)

-- Test Simple Text Input
RegisterCommand('input_test_simple', function()
    local simpleData = {
        inputs = {
            {
                text = "Enter your message",
                name = "message",
                type = "text",
                isRequired = true
            }
        }
    }
    
    local result = Input.Open("Simple Input", simpleData, true, "Send")
    if result then
        print("Simple Input Result: " .. (result.message or "No message"))
    else
        print("Simple Input: Cancelled")
    end
end, false)

-- Test All Input Types (QB Format)
RegisterCommand('input_test_all_types', function()
    local allTypesData = {
        inputs = {
            {
                text = "Text Input",
                name = "text_field",
                type = "text",
                isRequired = false,
                default = "Sample text"
            },
            {
                text = "Number Input",
                name = "number_field",
                type = "number",
                isRequired = false,
                default = 42
            },
            {
                text = "Password Input",
                name = "password_field",
                type = "password",
                isRequired = false
            },
            {
                text = "Radio Selection",
                name = "radio_field",
                type = "radio",
                isRequired = false,
                options = {
                    {value = "option1", text = "Option 1"},
                    {value = "option2", text = "Option 2"},
                    {value = "option3", text = "Option 3"}
                }
            },
            {
                text = "Checkbox Options",
                name = "checkbox_field",
                type = "checkbox",
                isRequired = false,
                options = {
                    {value = "check1", text = "Check 1", checked = true},
                    {value = "check2", text = "Check 2", checked = false},
                    {value = "check3", text = "Check 3", checked = false}
                }
            },
            {
                text = "Select Dropdown",
                name = "select_field",
                type = "select",
                isRequired = false,
                options = {
                    {value = "val1", text = "Value 1"},
                    {value = "val2", text = "Value 2"},
                    {value = "val3", text = "Value 3"}
                }
            }
        }
    }
    
    local result = Input.Open("All Input Types Test", allTypesData, true, "Test Submit")
    if result then
        print("All Types Result:", json.encode(result))
        
    else
        print("All Types: User cancelled")
    end
end, false)

-- Test Error Handling
RegisterCommand('input_test_error', function()
    -- Test with invalid data
    local result = Input.Open("Error Test", nil, true)
    if result then
        print("Error test unexpectedly succeeded")
    else
        print("Error test correctly handled nil data")
    end
    
    -- Test with empty inputs
    local emptyData = {inputs = {}}
    local result2 = Input.Open("Empty Test", emptyData, true)
    if result2 then
        print("Empty test result: " .. json.encode(result2))
    else
        print("Empty test: No result")
    end
end, false)

-- print("Input unit tests loaded. Available commands:")
-- print("  /input_test_qb - Test QB format input")
-- print("  /input_test_ox - Test Ox format input") 
-- print("  /input_test_simple - Test simple text input")
-- print("  /input_test_all_types - Test all input types")
-- print("  /input_test_error - Test error handling")