crossoverChance = 0.8
changeConnectionChance = 0.25
addConnectionChance = 0.5
addNodeChance = 0.5
perturbChance = 0.9
stepSize = 0.1
disableChance = 0.4
enableChance = 0.2
speciesPerGeneration = 100
inputRadius = 5
inputSize = (inputRadius * 2)*(inputRadius * 2) + 1
buttons = {"A", "B", "Up", "Down", "Left", "Right",}
outputSize = #buttons
inovationIndex = inputSize * outputSize + 1
saveFile = "SMB.state"


function activationFunction(x)
    return 1/(1+math.exp(-x))
end

function newNetwork(nInput, nOutput)
  local network = {}
  network.fitness = 0
  network.nInput = nInput
  network.nOuput = nOutput
  network.inputNeurons = {}
  network.outputNeurons = {}
  network.neurons = {}
  network.connections = {}
  network.nInput = nInput
  network.nOutput = nOutput
  network.nNeurons = nInput + nOutput
  network.nConnections = 0
  for i = 1, nInput, 1 do
    network.inputNeurons[i] = newInputNeuron(i)
    network.neurons[i] = network.inputNeurons[i]
  end
  for i = 1, nOutput, 1 do
    network.outputNeurons[i] = newNeuron(nInput + i)
    network.neurons[nInput + i] = network.outputNeurons[i]
  end
  network.sortedNeurons = {}
  return network
end


function addNeuron(network, neuronIndex)
  network.nNeurons = network.nNeurons + 1
  network.neurons[network.nNeurons] = newNeuron(neuronIndex)
end
function updateInput(network, inputArray)
  for i = 1, network.nInput, 1 do
    network.inputNeurons[i].output = inputArray[i]
  end
  local j = 1
  while network.sortedNeurons[j] do
    updateNeuron(network.sortedNeurons[j])
    j = j + 1
  end
end
function updateNeuron(neuron)
  local sumOutput = 0
  for i, k in ipairs(neuron.inputConnections) do
    if(k.enabled) then
      sumOutput = sumOutput + (k.inputNeuron.output * k.weight)
    end
  end
  neuron.output = activationFunction(sumOutput)
end
function addConnection(network, i, j, weight, connectionIndex, enabled)
  local inputNeuron = nil
  local outputNeuron = nil
  for k, v in ipairs(network.neurons) do
    if v.index == i then
      inputNeuron = v
      break
    end
  end
  for k, v in ipairs(network.neurons) do
    if v.index == j then
      outputNeuron = v
      break
    end
  end

  local connection = newConnection(inputNeuron, outputNeuron, weight, connectionIndex, enabled)
  network.nConnections = network.nConnections + 1
  network.connections[network.nConnections] = connection
end

function newConnection(inputNeuron, outputNeuron, weight, connectionIndex, enabled)
  local connection = {}
  connection.index = connectionIndex
  connection.inputNeuron = inputNeuron
  connection.outputNeuron = outputNeuron
  connection.enabled = enabled
  connection.weight = weight
  inputNeuron.nOutputConnections = inputNeuron.nOutputConnections + 1
  inputNeuron.outputConnections[inputNeuron.nOutputConnections] = connection
  outputNeuron.nInputConnections = outputNeuron.nInputConnections + 1
  outputNeuron.inputConnections[outputNeuron.nInputConnections] = connection
  return connection
end

function newNeuron(neuronIndex)
  local neuron = {}
  neuron.index = neuronIndex
  neuron.inputConnections = {}
  neuron.outputConnections = {}
  neuron.nInputConnections = 0
  neuron.nOutputConnections = 0
  neuron.output = 0
  return neuron
end

function newInputNeuron(neuronIndex)
  local neuron = {}
  neuron.index = neuronIndex
  neuron.outputConnections = {}
  neuron.nOutputConnections = 0
  neuron.output = 0
  return neuron
end

function topologicalSort(network)
    local alreadyVisited = newList()
    local sortedList = newList()
    for i, v in ipairs(network.inputNeurons) do
      for j, w in ipairs(v.outputConnections) do
        if not listHasValue(alreadyVisited, w.outputNeuron) then
          topologicalSortRec(w.outputNeuron, alreadyVisited, sortedList)
        end
      end
    end
    network.sortedNeurons = inverseArrayList(sortedList)
end
function topologicalSortRec(neuron, alreadyVisited, sortedList)
  addList(alreadyVisited, neuron)
  for i, v in ipairs(neuron.outputConnections) do
    if not listHasValue(alreadyVisited, v.outputNeuron) then
      topologicalSortRec(v.outputNeuron, alreadyVisited, sortedList)
    end
  end
  addList(sortedList, neuron)
end

function newList()
  local list = {}
  list.length = 0
  list.elements = {}
  return list;
end
function inverseArrayList(list)
  local array = {}
  local j = 1
  for i = list.length, 1, -1 do
    array[j] = list.elements[i]
    j = j + 1
  end
  return array
end
function addList(list, element)
  list.length = list.length + 1
  list.elements[list.length] = element
end
function listHasValue(list, value)
  for i, v in ipairs(list.elements) do
    if value == v then
      return true
    end
  end
  return false
end


function sumFitness(networks)
  local sum = 0
  for i, v in ipairs(networks) do
    sum = sum + v.fitness
  end
  return sum
end

function selectNetwork(networks, sum)
  local rndNum = math.random(0, sum)
  local checkSum = 0
  for i,v in ipairs(networks) do
    checkSum = checkSum + v.fitness
    if(rndNum <= checkSum) then
      return v
    end
  end
end

function copyNetwork(network)
  local copy = newNetwork(network.nInput, network.nOutput)
  for i = copy.nInput + copy.nOutput, copy.nNeurons, 1 do
    addNeuron(copy, network.neurons[i])
  end
  for i = 1, network.nConnections, 1 do
    addConnection(copy, network.connections[i].inputNeuron.index, network.connections[i].outputNeuron.index, network.connections[i].weight, network.connections[i].enabled)
  end
  topologicalSort(copy)
  return copy
end

function hasConnection(network, conenctionIndex)
  for i, v in ipairs(network.connections) do
    if(v.index == connectionIndex) then
      return true
    end
  end
  return false
end
function getConnection(network, connectionIndex)
  for i, v in ipairs(network.connections) do
    if(v.index == connectionIndex) then
      return v.inputNeuron.index, v.outputNeuron.index, v.weight, v.index, v.enabled
    end
  end
  return nil
end
function neatOperation(network1, network2)
  local crossNetwork = newNetwork(network1.nInput, network1.nOutput)
  local maxFitnessNetwork = nil
  local rndNum = 0
  if network1.fitness > network2.fitness then
    maxFitnessNetwork = network1
  else
    maxFitnessNetwork = network2
  end
  for i, v in ipairs(maxFitnessNetwork.connections) do
    if hasConnection(v.index) then
      rndNum = math.random()
      local maxNewConnection = nil
      if(rndNum <= 0.5) then
        addConnection(crossNetwork, getConnection(network1, v.index))
      else
        addConnection(crossNetwork, getConnection(network2, v.index))
      end
    else
      addConnection(crossNetwork, getConnection(maxFitnessNetwork, v.index))
    end
  end

  return crossNetwork
end
function crossover(networks, chance)
  local rndNum = math.random()
  local fitnessSum = sumFitness(networks)
  if(rndNum < chance) then
    return neatOperation(selectNetwork(networks, fitnessSum), selectNetwork(networks, fitnessSum))
  else
     rndNum = math.random(1, speciesPerGeneration)
     return copyNetwork(networks[rndNum])
  end
end

function mutateChangeConnection(network)
  local rndNum = math.random(1,#network.connections)
  print(rndNum .. " " .. #network.connections)
  local mutateConnection = network.connections[rndNum]

  if math.random() < perturbChance then
    mutateConnection.weight = mutateConnection.weight + math.random() * stepSize * 4 - stepSize
  else
    mutateConnection.weight = math.random() * 8 - 4
  end
end
function mutateAddNode(network)
  addNeuron(network, network.nNeurons + 1)
  local rndNum = math.random(1, #network.connections)
  local addNeuronConnection = network.connections[rndNum]
  addConnection(network, addNeuronConnection.inputNeuron.index, network.nNeurons, 1, inovationIndex, addNeuronConnection.enabled)
  inovationIndex = inovationIndex + 1
  addNeuronConnection.enabled = false
  addConnection(network, network.nNeurons, addNeuronConnection.outputNeuron.index,  addNeuronConnection.weight, inovationIndex, true)
  inovationIndex = inovationIndex + 1
end

function getNeuron(network, index)
  for i, v in ipairs(network.neurons) do
    if(v.index == index) then
      return v
    end
  end
  return nil
end


function mutation(network)
  local rndNum = math.random()
  if(math.random() <= addConnectionChance) then
    mutateAddConnection(network)
  end
  if math.random() <= addNodeChance then
    mutateAddNode(network)
  end
  if math.random() <= changeConnectionChance then
    mutateChangeConnection(network)
  end
  if(math.random() <= disableChance) then
    mutateDisableConnection(network)
  end
  if math.random() <= enableChance then
    mutateEnableConnection(network)
  end

  topologicalSort(network)
end
function mutateDisableConnection(network)
  local disableConnection = math.random(1, #network.connections)
  network.connections[disableConnection].enabled = false
end
function mutateEnableConnection(network)
  local enableConnection = math.random(1, #network.connections)
  network.connections[enableConnection].enabled = true
end
function isReachable(neuron, index)
  if(neuron.index == index) then
    return true
  end
  for i, v in ipairs(neuron.outputConnections) do
    if(v.outputNeuron.index == index) then
      return true
    end
  end
  for i, v in ipairs(neuron.outputConnections) do
    if(isReachable(v.outputNeuron, index)) then
      return true
    end
  end
  return false
end


function mutateAddConnection(network)
  local addNeuron1 = math.random(1, network.nNeurons)
  local addNeuron2 = math.random(1, network.nNeurons)
  if(addNeuron1 <= network.nInput and addNeuron2 <= network.nInput) then
    return
  elseif addNeuron2 <= network.nInput then
    local aux = addNeuron2
    addNeuron2 = addNeuron1
    addNeuron1 = addNeuron2
  else
    local neuron1 = getNeuron(network, addNeuron1)
    local neuron2 = getNeuron(network, addNeuron2)
    if((not isReachable(neuron2, neuron1.index)) and (not isReachable(neuron1, neuron2.index))) then
      addConnection(network, neuron1.index, neuron2.index, math.random() * 8 - 4, inovationIndex, true)
      inovationIndex = inovationIndex + 1
    end
  end
end

function generateRandomPerceptron()
  local network = newNetwork(inputSize, outputSize)
  local k = 1
  local rndNum
  for i = 1, inputSize, 1 do
    for j = 1, outputSize, 1 do
      rndNum = math.random()
      addConnection(network, i, inputSize + j, math.random() * 8 - 4, k, rndNum <= 0.5)
      k = k + 1
    end
  end
  topologicalSort(network)
  return network
end

-- math
function position()
     mario["y"] = memory.readbyte(0x03B8) -- +16 2 blocos?
     mario["x"] = memory.readbyte(0x0086) + memory.readbyte(0x006D) -- * 0x0100
     tela["x"] = memory.readbyte(0x03AD) --Player x pos within current screen offset
     tela["y"] = memory.readbyte(0x03B8) --Player y pos within current screen (vertical screens always offset at 0?)
end

function verificaBloco(posX, posY)
    local x = marioX + posX + 8
    local y = marioY + posY - 16
    local page = math.floor(x / 256) % 2

    local subx = math.floor((x % 256)/16)
    local suby = math.floor((y - 32)/16)
    local addr = 0x500 + page*13*16 + suby*16 + subx --Current tile

    if suby >= 13 or suby < 0 then
        return 0
    end

    if memory.readbyte(addr) == 1 then -- Verifica se existe um bloco na posicao
        return 1
    else
        return 0
    end
end

function verificaInimigo(posX, posY)
    local inimigos = {}
    for i = 0, 4 do -- maximos de inimigos na tel = 5
        local inimigo = memory.readbyte(0x000F + i) -- Enemy drawn? 0 - No 1 - Yes
        if inimigo == 1 then
            --calcular posição do inimigo
            -- 0x006E Enemy horizontal position in level
            local inimigoX = memory.readbyte(0x006E + i)*0x100 + memory.readbyte(0x0087 + i) -- Enemy horizontal position in level
            local inimigoY = memory.readbyte(0x00CF + i) + 24 -- Enemy y pos on screen
            inimigos[#inimigos + 1] = {["x"]=inimigoX,["y"]=inimigoY}
        end
    end
    return inimigos
end

function entradas()
    position()
    inimigos = verificaInimigo()
    local entrada = {}
    
    for posY = -inputRadius, inputRadius do
        for posX = - inputRadius, inputRadius do
            entrada[#entrada + 1] = 0
            if verificaBloco(posX, posY) == 1 --and mario["y"] + posY < 0x01B0
                entrada[#entrada] = 1
            end
        end

        for i = 1, # inimigos do
            dx = math.abs(inimigos[i]["x"] - mario["x"] + posX)
            dy = math.abs(inimigos[i]["y"] - mario["y"] + posY)
            if dx <= 8 and dy <= 8 then
                entrada[#entrada] = - 1
            end
        end
    end
    return entrada
end
--

local function main()
  math.randomseed(os.time())
  math.random()
  math.random()
  math.random()
  net = generateRandomPerceptron()
--  net = newNetwork(3, 4)
--  addNeuron(net, 8)
--  addNeuron(net, 9)
--  addConnection(net, 1, 8, 4,1, true)
--  addConnection(net, 8, 5, -3,2, true)
--  addConnection(net, 2, 4, 2, 3, true)
--  addConnection(net, 3, 9, 4, 4, true)
--  addConnection(net, 8, 9, 3, 5, true)
--  addConnection(net, 9, 7, 6, 6, true)
--  topologicalSort(net)
--  inputTeste = {8, -5, 2}
--  updateInput(net, inputTeste)
  teste = net.connections
  for i, v in ipairs(teste) do
    print(v.index .. " - " .. v.inputNeuron.index .. " -> " .. v.outputNeuron.index)
  end
  print("----------------")
  mutateAddNode(net)
  for i, v in ipairs(teste) do
    print(v.index .. " - " .. v.inputNeuron.index .. " -> " .. v.outputNeuron.index)
  end
  gameLoop()
end

function gameLoop(){
    


    emu.frameadvance();
    gameLoop()    
}
main()
