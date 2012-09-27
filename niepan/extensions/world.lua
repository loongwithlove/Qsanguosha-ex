module("extensions.world",package.seeall)
extension=sgs.Package("world")

--CL 就是world包作者本人啦，超神也可以理解么。
CL = sgs.General(extension,"CL","god",3)
god = sgs.CreateTriggerSkill
{--”在这片领域里，CL拥有近乎神的力量。“CL的信徒这样说到
	name = "god",
	frequency = sgs.Skill_compulsory,
	events = {sgs.Damaged,sgs.Dying,sgs.PhaseChange},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			room:playSkillEffect("paoxiao",2)
			end
		if event == sgs.Damaged then
		local damage = data:toDamage()
		room:playSkillEffect("paoxiao",3)
		local x = player:getMaxHp() - player:getHp() + 1
		for var = 1, x, 1 do   
			player:drawCards(2)   
			local hnum = player:getHandcardNum() 
			local cdlist = sgs.IntList()   
			cdlist:append(player:handCards():at(hnum-1))   
			cdlist:append(player:handCards():at(hnum-2))   
			room:askForYiji(player, cdlist)   
			if(player:getHandcardNum() == hnum-1) then
				celist = sgs.IntList()
				celist:append(player:handCards():at(hnum-2))
				room:askForYiji(player, celist)
			end
		end
		end
		if event == sgs.Dying then
		  room:playSkillEffect("paoxiao",4)
		  local recover = sgs.RecoverStruct()
		  recover.who = player
		  recover.recover = 2
		  recover.reason = player:objectName()
		  room:recover(player,recover)	
		end
	end
}

CL:addSkill(god)

sgs.LoadTranslationTable{
	["#CL"] = "近神的男人",
	["$paoxiao2"] = "风劲角弓鸣，将军猎渭城",
	["$paoxiao3"] = "草枯鹰眼疾，雪尽马蹄轻",
	["$paoxiao4"] = "回看射雕处，千里暮云平",
}
	
--真＊袁术
true_yuanshu = sgs.General(extension,"true_yuanshu","qun",4)

yonglu = sgs.CreateTriggerSkill{
  frequency = sgs.Skill_compulsory,

  name = "yonglu",
  
  events = {sgs.DrawNCards,sgs.PhaseChange},
  
  on_trigger = function(self,event,player,data)
  
    local room = player:getRoom()
    
    local getAlive = function()
      local alive_num = 0
      local players = room:getAlivePlayers()
      for _,aplayer in sgs.qlist(players) do
	  alive_num = alive_num + 1
      end
    if alive_num > 5 then alive_num = 5 end
    return alive_num
    end
    
    
    if event == sgs.DrawNCards then
      room:playSkillEffect("yonglu")
      data:setValue(data:toInt()+getAlive())
      room:playSkillEffect("yongsi",1)
    elseif (event == sgs.PhaseChange) and ( player:getPhase() == sgs.Player_Discard ) then
      local x = getAlive()
      local e = player:getEquips():length() + player:getHandcardNum()
      if e > x then room:askForDiscard(player,"yonglu",x,x,false,true)
      else
	player:throwAllHandCards()
	player:throwAllEquips()
      end
    end
  end
}

sgs.LoadTranslationTable{
	["true_yuanshu"]="真＊袁术",
	["#true_yuanshu"] = "四世三公",
	["yonglu"] = "庸碌",
	[":yonglu"] = "<b>锁定技，</b>摸牌阶段，你额外摸X张牌;弃牌阶段，你至少须弃掉X张牌(不足则全弃)，X为场上现存玩家数，且X最高为5。",
	["designer:true_yuanshu"] = "CL",
	["cv:true_yuanshu"] = "暂无",
}
true_yuanshu:addSkill(yonglu)
true_yuanshu:addSkill("weidi")

--陆小凤
luxiaofeng = sgs.General(extension,"luxiaofeng","wei",4)

steal_card = sgs.CreateSkillCard
{
	name = "steal",	
	target_fixed = false,	
	will_throw = false,
	
	filter = function(self, targets, to_select)
		if(#targets > 0) then return false end
		
		if(to_select == self) then return false end
		
		return not to_select:isKongcheng()
	end,
		
	on_effect = function(self, effect)
		local from = effect.from
		local to = effect.to
		local room = to:getRoom()
		local card_id = room:askForCardChosen(from, to, "h", "steal")
		local card = sgs.Sanguosha:getCard(card_id)
		room:moveCardTo(card, from, sgs.Player_Hand, false)
		room:playSkillEffect("paoxiao",2)
		if to:getHandcardNum() < 1 then from:drawCards(2) return true end
		if to:getHandcardNum() > 0 then
		local card_id = room:askForCardChosen(from, to, "h", "steal")
		local card = sgs.Sanguosha:getCard(card_id)
		room:moveCardTo(card, from, sgs.Player_Hand, false)
		return true end
		
		room:setEmotion(to, "bad")
		room:setEmotion(from, "good")
	end,
}

steal_viewas = sgs.CreateViewAsSkill
{
	name = "steal_viewas",	
	n = 0,
	
	view_as = function()
		return steal_card:clone()		
	end,
	
	enabled_at_play = function()
		return false
	end,
	
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@steal"
	end
}

steal = sgs.CreateTriggerSkill
{
	name = "steal",
	view_as_skill = steal_viewas,
	events = {sgs.PhaseChange},
	
	on_trigger = function(self, event, player, data)
		if(player:getPhase() == sgs.Player_Draw) then
			local room = player:getRoom()
			local other = room:getOtherPlayers(player)
			if(not room:askForSkillInvoke(player, "steal")) then return false end
			if room:askForUseCard(player, "@@steal", "@steal_card") then return true end
		end
	end
}
sgs.LoadTranslationTable{
	["luxiaofeng"]="陆小凤",
	["#luxiaofeng"] = "四条眉毛",
	["steal"] = "侠探",
	[":steal"] = "摸牌阶段，你可从另一名角色手里抽2张牌，若该角色手牌只有1张，你将摸两张牌。",
	["~steal"] = "摸牌阶段，你可从另一名角色手里抽2张牌，若该角色手牌只有1张，你将摸两张牌。",
	["@steal_card"] = "侠探",
	["$paoxiao2"] = "咦，你的手牌呢？";
	["designer:luxiaofeng"] = "CL",
	["cv:luxiaofeng"] = "暂无",
}
luxiaofeng:addSkill(steal)

--真＊郭嘉 作者：『両儀式』
luaguojia=sgs.General(extension, "luaguojia", "wei", "3", false)
shisheng=sgs.CreateTriggerSkill{
	name="shisheng",
	events={sgs.Damaged,sgs.PhaseChange},
	can_trigger=function()
		return true
	end,
	on_trigger=function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local to   = damage.to
		local from = damage.from
		local skillowner=room:findPlayerBySkillName("shisheng")
				if event==sgs.Damaged  and player:isAlive() and damage.from~=nil and to:isAlive() and from:isAlive() and skillowner:askForSkillInvoke("shisheng") then
			local judge=sgs.JudgeStruct()
				judge.pattern=sgs.QRegExp("(.*):(.*):(.*)")
				judge.reason="shisheng"
				judge.who=to
				room:judge(judge)
				if judge.card:getSuit()== sgs.Card_Spade or judge.card:getSuit()== sgs.Card_Club then
					local recover = sgs.RecoverStruct()
					recover.who = to
					recover.recover = 1
					recover.reason = to:objectName()
					room:recover(to,recover)
				end
				if judge.card:getSuit()== sgs.Card_Diamond or judge.card:getSuit()== sgs.Card_Heart then
					local recover = sgs.RecoverStruct()
					recover.who = from
					recover.recover = 1
					recover.reason = from:objectName()
					room:recover(from,recover)
				end
		end
	end,
}
shibai=sgs.CreateTriggerSkill{
	name="shibai",
	events={sgs.Damaged,sgs.PhaseChange},
	can_trigger=function()
		return true
	end,
	on_trigger=function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local to   = damage.to
		local from = damage.from
		local skillowner=room:findPlayerBySkillName("shibai")
		if event==sgs.Damaged  and player:isAlive() and damage.from~=nil and to:isAlive() and from:isAlive() and skillowner:askForSkillInvoke("shibai") then
			local judge=sgs.JudgeStruct()
				judge.pattern=sgs.QRegExp("(.*):(.*):(.*)")
				judge.reason="shibai"
				judge.who=to
				room:judge(judge)
				if judge.card:getSuit()== sgs.Card_Spade or judge.card:getSuit()== sgs.Card_Club then
					room:loseHp(to,1)
				end
				if judge.card:getSuit()== sgs.Card_Diamond or judge.card:getSuit()== sgs.Card_Heart then
					room:loseHp(from,1)
				end
		end
	end,
}
guimou_card=sgs.CreateSkillCard{
	name = "guimou_card",
	target_fixed = true,
	will_throw = false,
}
guimouvs = sgs.CreateViewAsSkill{
	name = "guimouvs",
	n = 1,
	view_filter = function(self, selected, to_select)        
			return true
	end,
	view_as = function(self, cards)
			if #cards == 1 then 
			local acard = guimou_card:clone()        
			acard:addSubcard(cards[1])        
			acard:setSkillName("guimou")
			return acard end
	end,
	enabled_at_play = function()
			return false        
	end,
	enabled_at_response = function(self, player, pattern)
			return pattern == "@@guimou"       
	end
}
guimou = sgs.CreateTriggerSkill{
	name = "guimou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForRetrial},
	view_as_skill = guimouvs,
	on_trigger=function(self,event,player,data)
		local room = player:getRoom()
        local ssmy = room:findPlayerBySkillName("guimou")
		if ssmy == nil then return false end
        local judge = data:toJudge()
		ssmy:setTag("Judge", data)
        if not room:askForSkillInvoke(ssmy, "guimou") then return false end 
		--player:unicast(string.format("%s %s","animate","lightbox:$guimou")) --播放全屏文字
		room:playSkillEffect("guimou", 1)
        local card = room:askForCard(ssmy,"@guimou","@guimou",data)
        if card ~= nil then
			ssmy:obtainCard(judge.card)
			judge.card = sgs.Sanguosha:getCard(card:getEffectiveId())
			room:moveCardTo(judge.card, nil, sgs.Player_Special)
			--local log = sgs.LogMessage()
            --log.type = "$ChangedJudge"
            --log.from = player
            --log.to:append(judge.who)
            --log.card_str = card:getEffectIdString()
            --room:sendLog(log)
			room:sendJudgeResult(judge)
			room:loseHp(player,1)
        end
        return false 
    end,
}


luaguojia:addSkill(guimou)
luaguojia:addSkill(shisheng)
luaguojia:addSkill(shibai)
sgs.LoadTranslationTable{ 
	["luaguojia"]="真＊郭嘉",
	["guimou"]="鬼谋",
	["guimou_card"]="鬼谋",
	["shibai"]="十败",
	[":shibai"]="当有角色受到伤害后你可以令其进行1次判定，判定为黑色，该角色失去1点体力，不为黑色则伤害来源失去1点体力。",
	["@guimou"]="包括装备，不信你点",
	[":guimou"]="在1名角色的判定牌生效前，你可以打出1张牌替换之，然后你失去1体力。",
	["~guimou"]="小心流失体力哦，亲~~~",
	["shisheng"]="十胜",
	[":shisheng"]="当有角色受到伤害后你可以令其进行1次判定，判定为黑色，该角色回复1点体力，不为黑色则伤害来源回复1点体力。",
	--设计者(不写默认为官方)
	["designer:luaguojia"] = "『両儀式』",
	--配音(不写默认为官方)
	["cv:luaguojia"] = "暂无",
	--称号
	["#luaguojia"] = "天生奇才",
	--插画(默认为KayaK)
	["illustrator:luaguojia"] = "『両儀式』",
}

--龟丞相
Turtle_Prime_Minister = sgs.General(extension,"Turtle_Prime_Minister","wu",5)

shuixi = sgs.CreateTriggerSkill
{
  name = "shuixi",
  frequency = Skill_Frequent,
  events = {sgs.PhaseChange},
 
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    if ( player:getPhase() == sgs.Player_Start ) then
      if not room:askForSkillInvoke(player,"shuixi") then return false end
      player:turnOver()
      local x = player:getMaxHp() - player:getHp()
      player:drawCards(x+2)
      return true
    end
end
}

guisuo = sgs.CreateTriggerSkill
{--”龟丞相傻乎乎的龟缩一下也是正常的么。何况本来就翻面了。“CL这样说到
	name = "guisuo",
	frequency = sgs.Skill_compulsory,
	events = {sgs.Damaged},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if player:faceUp() then return false end
		
		room:playSkillEffect("guisuo")
		local x = player:getMaxHp() - player:getHp()
		player:drawCards(x)
		
	end
}

Turtle_Prime_Minister:addSkill(shuixi)
Turtle_Prime_Minister:addSkill(guisuo)

sgs.LoadTranslationTable{ 
	["Turtle_Prime_Minister"]="龟丞相",
	["guisuo"]="龟缩",
	[":guisuo"]="锁定技，当你翻面受到伤害时，你将摸X张牌，X为你已损失的体力值。",
	["shuixi"]="水吸",
	[":shuixi"]="回合开始阶段，龟丞相可以吸收水的威能，摸2+X张牌，并将武将牌翻面,X为你已损失的体力值。",
	["@shuixi"]="龟丞相可以吸收水的威能，并以此增强自己的法力。",
	["designer:Turtle_Prime_Minister"] = "CL",
	["cv:Turtle_Prime_Minister"] = "暂无",
	["#Turtle_Prime_Minister"] = "龙王智囊",
	["illustrator:Turtle_Prime_Minister"] = "暂无",
}

--独孤不败
duguqiubai = sgs.General(extension,"duguqiubai","qun",3)

wuzhao = sgs.CreateTriggerSkill
{
  name = "wuzhao",
  frequency = sgs.Skill_NotFrequent,
  events = {sgs.DamageCaused},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local damage = data:toDamage()
    local x = damage.damage
    local e = damage.to:getEquips():length() + damage.to:getHandcardNum()
    if x > e then x = e end
    if not room:askForSkillInvoke(player,"wuzhao") then return false end
    for var = 1, x, 1 do
      if e == 0 then return false end
      local card_id = room:askForCardChosen(damage.from, damage.to, "hej", "wuzhao")
      room:playSkillEffect("fankui",1)
      room:moveCardTo(sgs.Sanguosha:getCard(card_id), damage.from, sgs.Player_Hand, false)
    end
end
}

jiujian = sgs.CreateTriggerSkill
{
  name = "jiujian",
  frequency = sgs.Skill_Frequent,
  events = {sgs.DrawNCards},
  
  on_trigger = function(self, event, player, data)
    if event == sgs.DrawNCards then
      local room = player:getRoom()
      local x = ( 4 - player:getEquips():length() )/2
      if not room:askForSkillInvoke(player,"jiujian") then return false end
      room:playSkillEffect("jiujian",1)
      data:setValue(data:toInt()+x+1)
    end
end
}

wujian=sgs.CreateTriggerSkill{
	name = "wujian",
	frequency = sgs.Skill_Wake,
	events = {sgs.Dying},
	    
	on_trigger=function(self,event,player,data)
		if event == sgs.Dying then
			local room = player:getRoom()
			local curMaxHp = player:getMaxHp()
			room:setPlayerProperty(player, "maxhp",sgs.QVariant(curMaxHp+1))
			local recover = sgs.RecoverStruct()
			recover.who = player
			recover.recover = 2
			recover.reason = player:objectName()
			room:recover(player,recover)
			room:acquireSkill(player,"jiujian")
			player:addMark("wujian")
			local log = sgs.LogMessage()
			log.from = player
			log.type = "#wujian"
			room:sendLog(log)
			return true end
	end,
	
	can_trigger=function(self,player)
		return player:hasSkill(self:objectName()) and (player:getMark("wujian")==0)
	end
}

local skill=sgs.Sanguosha:getSkill("jiujian")
if not skill then
	local skillList=sgs.SkillList()
	skillList:append(jiujian)
	sgs.Sanguosha:addSkills(skillList)
end
    
duguqiubai:addSkill(wuzhao)
duguqiubai:addSkill(wujian)
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("jiujian") then skills:append(jiujian) end

sgs.LoadTranslationTable{ 
	["duguqiubai"]="独孤求败",
	["wuzhao"]="无招",
	[":wuzhao"]="当你即将造成X点伤害时，你可获得伤害目标X张牌",
	["wujian"] = "悟剑",
	[":wujian"] = "觉醒技，当你濒死时，你将增加1点体力上限并回复2点体力，然后获得技能［九剑］。",
	["#wujian"] = "在这生死攸关的一刻，独孤先生似乎领悟了什么，但又似乎什么也不知道。－－CL的信徒这样说到",
	["jiujian"]="九剑",
	[":jiujian"]="摸牌阶段，你可多摸X张牌，X＝(4-你装备数目)/2＋1。",
	["designer:duguqiubai"] = "CL",
	["cv:duguqiubai"] = "暂无",
	["#duguqiubai"] = "剑魔",
	["illustrator:duguqiubai"] = "暂无",
}
