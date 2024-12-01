-- Criação da GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local MinimizeButton = Instance.new("TextButton")
local PlayerDropdown = Instance.new("TextButton")
local DropdownList = Instance.new("ScrollingFrame")
local MessageBox = Instance.new("TextBox")
local ExecuteButton = Instance.new("TextButton")

-- Propriedades da GUI
ScreenGui.Name = "KickGui"
ScreenGui.Parent = game.CoreGui

Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.Active = true
Frame.Draggable = true

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = Frame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Size = UDim2.new(0, 50, 0, 25)
MinimizeButton.Position = UDim2.new(1, -55, 0, 5)
MinimizeButton.Text = "-"

PlayerDropdown.Name = "PlayerDropdown"
PlayerDropdown.Parent = Frame
PlayerDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlayerDropdown.Size = UDim2.new(0, 280, 0, 30)
PlayerDropdown.Position = UDim2.new(0, 10, 0, 40)
PlayerDropdown.Text = "Selecionar Jogador"

DropdownList.Name = "DropdownList"
DropdownList.Parent = PlayerDropdown
DropdownList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DropdownList.Size = UDim2.new(0, 280, 0, 100)
DropdownList.Position = UDim2.new(0, 0, 1, 0)
DropdownList.Visible = false
DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)

MessageBox.Name = "MessageBox"
MessageBox.Parent = Frame
MessageBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MessageBox.Size = UDim2.new(0, 280, 0, 30)
MessageBox.Position = UDim2.new(0, 10, 0, 80)
MessageBox.PlaceholderText = "Digite uma mensagem..."

ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Parent = Frame
ExecuteButton.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ExecuteButton.Size = UDim2.new(0, 280, 0, 40)
ExecuteButton.Position = UDim2.new(0, 10, 0, 120)
ExecuteButton.Text = "Executar"

-- Função para preencher a lista de jogadores
local function UpdatePlayerList()
    DropdownList:ClearAllChildren()
    local players = game.Players:GetPlayers()
    for _, player in ipairs(players) do
        local PlayerButton = Instance.new("TextButton")
        PlayerButton.Size = UDim2.new(1, 0, 0, 25)
        PlayerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        PlayerButton.Text = player.Name
        PlayerButton.Parent = DropdownList
        PlayerButton.MouseButton1Click:Connect(function()
            PlayerDropdown.Text = player.Name
            DropdownList.Visible = false
        end)
    end
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, #players * 25)
end

-- Eventos
PlayerDropdown.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
    if DropdownList.Visible then
        UpdatePlayerList()
    end
end)

MinimizeButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    if Frame.Visible then
        MinimizeButton.Text = "-"
    else
        MinimizeButton.Text = "+"
    end
end)

ExecuteButton.MouseButton1Click:Connect(function()
    local selectedPlayer = PlayerDropdown.Text
    if selectedPlayer ~= "Selecionar Jogador" and selectedPlayer ~= "" then
        require(7740343097).kick(selectedPlayer)
    else
        print("Selecione um jogador válido!")
    end
end)
