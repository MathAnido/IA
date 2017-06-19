if gameinfo.getromname() == "Super Mario World (USA)" then
  Filename = "SMW1.state"
  ButtonNames = {
    "A",
    "B",
    "X",
    "Y",
    "Up",
    "Down",
    "Left",
    "Right",
  }
elseif gameinfo.getromname() == "Super Mario Brons." then
  Filename = "SMB1.state"
  ButtonNames = {
    "A",
    "B",
    "Up",
    "Down",
    "Left",
    "Right",
  }
end

function calculaPosicao()
  if gameinfo.getromname() == "Super Mario Bros." then
    xMario = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
    yMario = memory.readbyte(0x03B8) + 16
    xTela = memory.readbyte(0x03AD)
    yTela = memory.readbyte(0x03B8)
  end
end



function limparControle()
  controle = {}
  for btn = 1, #ButtonNames do
    controle["P1 " .. ButtonNames[btn]] = false
  end
  joypad.set(controle)
end

function fechar()
  forms.destroy(form)
end

-- Janela de controller
form = forms.newform(400, 260,"Platform Runner")
--geracaoLabel = forms.label(form, "Geracao: " .. " Especie: " .. " Genoma: ", 5, 8)
maxFitnessLabel = forms.label(form, "Max Fitness: ", 5, 8) -- .. math.floor(pool.maxFitness)
hideBanner = forms.checkbox(form, "Esconder Banner", 5 , 190)
-- Fim Janela

while true do
  local backgroundColor = 0xD0FFFFFF
  if not forms.ischecked(hideBanner) then
	   gui.drawBox(0, 210, 300, 240, backgroundColor, backgroundColor)
  end
  gui.drawText(0,210, "Ger. " .. "02" .. " Esp. " .. "00" .. " Gen. " .. "00 ( )", 0xff000000, 11)
  gui.drawText(0, 220, "Fitness: " .. "0000", 0xFF000000, 11)
  gui.drawText(100, 220, "Max Fitness: " .. "0000", 0xFF000000, 11)
  emu.frameadvance();
end
