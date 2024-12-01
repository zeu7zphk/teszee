-- Kick Manager GUI Script
-- Gerenciador de kicks com interface gráfica para Roblox

-- String manipulation functions
local v0=string.char
local v1=string.byte
local v2=string.sub
local v3=bit32 or bit
local v4=v3.bxor
local v5=table.concat
local v6=table.insert

local function v7(v60,v61)
    local v62={}
    for v71=1, #v60 do
        v6(v62,v0(v4(v1(v2(v60,v71,v71 + 1)),v1(v2(v61,1 + (v71% #v61),1 + (v71% #v61) + 1)))%256))
    end
    return v5(v62)
end

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
    local playerName = PlayerNameTextBox.Text
    if playerName and playerName ~= "" then
        game:GetService(v7("\226\215\218\55\242\190\213\57\196\202","\126\177\163\187\69\134\219\167")):SetCore(v7("\16\200\36\193\210\44\217\35\195\245\32\204\62\204\243\45","\156\67\173\74\165"),{
            [v7("\0\190\93\26\185","\38\84\215\41\118\220\70")]=v7("\126\25\54\27\248\89\21\35\6\247\95\24","\158\48\118\66\114"),
            [v7("\159\33\8\34","\155\203\68\112\86\19\197")]=playerName,
            [v7("\213\84\168\72","\38\156\55\199")]=v7("\186\127\100\41\0\103\255\87\161\121\38\103\92\37\171\20\249\46\47\123\69\39\170\18","\35\200\29\28\72\115\20\154"),
            [v7("\61\170\195\222\153\37\59\23","\84\121\223\177\191\237\76")]=10
        })
    end
end)

-- Inicialização
updatePlayerList()
