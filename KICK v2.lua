-- Kick Manager GUI Script
-- Gerenciador de kicks com interface gráfica para Roblox

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Criação da GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KickManagerGUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)  -- Aumentado para acomodar a lista
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
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

-- ScrollingFrame para lista de jogadores
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Name = "PlayerList"
PlayerList.Size = UDim2.new(1, -20, 0, 200)
PlayerList.Position = UDim2.new(0, 10, 0, 40)
PlayerList.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 6
PlayerList.Parent = MainFrame

-- Campo de nome do jogador
local PlayerNameTextBox = Instance.new("TextBox")
PlayerNameTextBox.Name = "PlayerNameTextBox"
PlayerNameTextBox.Size = UDim2.new(1, -20, 0, 40)
PlayerNameTextBox.Position = UDim2.new(0, 10, 0, 250)
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
KickButton.Position = UDim2.new(0, 10, 0, 300)
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
local selectedPlayer = nil

-- Função para criar botão de jogador
local function createPlayerButton(player)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, (#PlayerList:GetChildren() * 35))
    button.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    button.Text = player.Name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.Parent = PlayerList
    
    button.MouseButton1Click:Connect(function()
        selectedPlayer = player
        PlayerNameTextBox.Text = player.Name
        -- Reset cor de todos os botões
        for _, btn in ipairs(PlayerList:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            end
        end
        -- Destacar botão selecionado
        button.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    end)
    
    return button
end

-- Função para atualizar lista de jogadores
local function updatePlayerList()
    -- Limpar lista atual
    for _, item in ipairs(PlayerList:GetChildren()) do
        item:Destroy()
    end
    
    -- Adicionar jogadores atuais
    for _, player in ipairs(Players:GetPlayers()) do
        createPlayerButton(player)
    end
    
    -- Atualizar tamanho do ScrollingFrame
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 35)
end

-- Eventos de atualização da lista
Players.PlayerAdded:Connect(function(player)
    createPlayerButton(player)
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 35)
end)

Players.PlayerRemoving:Connect(function(player)
    if selectedPlayer == player then
        selectedPlayer = nil
        PlayerNameTextBox.Text = ""
    end
    updatePlayerList()
end)

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
    if selectedPlayer then
        require(7740343097).kick(selectedPlayer.Name)
    end
end)

-- Inicialização
updatePlayerList()
