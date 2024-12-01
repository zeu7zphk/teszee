-- Kick Manager GUI Script
-- Gerenciador de kicks com interface gráfica para Roblox

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Criação da GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KickManagerGUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Kick Manager"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botão minimizar
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Parent = TitleBar

-- Campo de nome do jogador
local PlayerNameTextBox = Instance.new("TextBox")
PlayerNameTextBox.Name = "PlayerNameTextBox"
PlayerNameTextBox.Size = UDim2.new(1, -20, 0, 40)
PlayerNameTextBox.Position = UDim2.new(0, 10, 0, 40)
PlayerNameTextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
PlayerNameTextBox.PlaceholderText = "Nome do jogador..."
PlayerNameTextBox.Text = ""
PlayerNameTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerNameTextBox.TextSize = 14
PlayerNameTextBox.Font = Enum.Font.SourceSans
PlayerNameTextBox.Parent = MainFrame

-- Botão de kick
local KickButton = Instance.new("TextButton")
KickButton.Name = "KickButton"
KickButton.Size = UDim2.new(1, -20, 0, 40)
KickButton.Position = UDim2.new(0, 10, 0, 90)
KickButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
KickButton.Text = "Kick Jogador"
KickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KickButton.TextSize = 16
KickButton.Font = Enum.Font.SourceSansBold
KickButton.Parent = MainFrame

-- Variáveis de controle
local isDragging = false
local dragStart = nil
local startPos = nil
local isMinimized = false
local originalSize = MainFrame.Size

-- Eventos de arrastar
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Evento de minimizar
MinimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Size = originalSize
        MinimizeButton.Text = "-"
    else
        MainFrame.Size = UDim2.new(0, 300, 0, 30)
        MinimizeButton.Text = "+"
    end
    isMinimized = not isMinimized
end)

-- Evento de kick
KickButton.MouseButton1Click:Connect(function()
    local playerName = PlayerNameTextBox.Text
    if playerName and playerName ~= "" then
        require(7740343097).kick(playerName)
    end
end)
