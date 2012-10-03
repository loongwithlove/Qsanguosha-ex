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
	["#CL"] = "包作者",
	["$paoxiao2"] = "风劲角弓鸣，将军猎渭城",
	["$paoxiao3"] = "草枯鹰眼疾，雪尽马蹄轻",
	["$paoxiao4"] = "回看射雕处，千里暮云平",
	["designer:CL"] = "CL",
	["cv:CL"] = "暂无",
	["illustrator:CL"] = "暂无",
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
	["#duguqiubai"] = "剑魔",
	["wuzhao"]="无招",
	[":wuzhao"]="当你即将造成X点伤害时，你可获得伤害目标X张牌",
	["wujian"] = "悟剑",
	[":wujian"] = "觉醒技，当你濒死时，你将增加1点体力上限并回复2点体力，然后获得技能［九剑］。",
	["#wujian"] = "在这生死攸关的一刻，独孤先生似乎领悟了什么，但又似乎什么也不知道。－－CL的信徒这样说到",
	["jiujian"]="九剑",
	[":jiujian"]="摸牌阶段，你可多摸X张牌，X＝(4-你装备数目)/2＋1。",
	["designer:duguqiubai"] = "CL",
	["cv:duguqiubai"] = "暂无",
	["illustrator:duguqiubai"] = "暂无",
}

-- 星矢
xingshi = sgs.General(extension,"xingshi","shu",4)

liuxing=sgs.CreateTriggerSkill
{--流星 “星矢的天马流星拳太威武了，CL启示我们是因为星矢领悟了第七感”CL的信徒这样说到
name="liuxing",
events={sgs.CardUsed},
frequency = sgs.Skill_NotFrequent,

on_trigger=function(self,event,player,data)
	local room=player:getRoom()	
	local selfplayer=room:findPlayerBySkillName(self:objectName())
	local otherplayers=room:getOtherPlayers(selfplayer)
	
	if event==sgs.CardUsed then
		local use=data:toCardUse()
		if not use.from:hasSkill(self:objectName()) then return false end
		if use.card==nil then return false end
		if not use.card:inherits("Slash") then return false end
		if selfplayer:hasFlag("liuxing_tmp") then return false end
		if (room:askForSkillInvoke(selfplayer,self:objectName(),data)~=true) then return false end
		local pfc=room:getOtherPlayers(selfplayer)
		local pfc_t=room:getOtherPlayers(selfplayer)
		for _,p in sgs.qlist(pfc_t) do
			if not selfplayer:canSlash(p) then pfc:removeOne(p) end				
		end
		for _,target in sgs.qlist(use.to) do
			local b=false
			for _,p in sgs.qlist(pfc) do
				if target:objectName()==p:objectName() then b=true end				
			end		
		end
		local pc=room:askForPlayerChosen(selfplayer,pfc,self:objectName())
		if pc==nil then return false end
		use.to:append(pc)
		room:setPlayerFlag(selfplayer,"liuxing_tmp")
		room:useCard(use)
		room:setPlayerFlag(selfplayer,"-liuxing_tmp")
		return true
	end	
end,
can_trigger=function(self, player)
	local room=player:getRoom()
	local selfplayer=room:findPlayerBySkillName(self:objectName())
	if selfplayer==nil then return false end
	return selfplayer:isAlive()
end
}

xingshi:addSkill(liuxing)

sgs.LoadTranslationTable{
	["xingshi"] = "星矢",
	["#xingshi"] = "天马座",
	[":xingshi"] = "沙织小姐，我...",
	["liuxing"] = "流星",
	[":liuxing"] = "你的每张【杀】可以同时对攻击距离内的两名角色使用，或者对同一角色使用两次。",
	["designer:xingshi"] = "CL",
	["cv:xingshi"] = "暂无",
	["illustrator:xingshi"] = "暂无",
}
	
-- 真＊张辽
true_zhangliao = sgs.General(extension,"true_zhangliao","wei",4)

truetuxi_card = sgs.CreateSkillCard
{--真＊突袭 技能卡
	name = "truetuxi",	
	target_fixed = false,	
	will_throw = false,
	
	filter = function(self, targets, to_select)
		if(#targets > 1) then return false end
		
		if(to_select == self) then return false end
		
		return not to_select:isKongcheng()
	end,
		
	on_effect = function(self, effect)
		local from = effect.from
		local to = effect.to
		local room = to:getRoom()
		local card_id = room:askForCardChosen(from, to, "h", "truetuxi_main")
		local card = sgs.Sanguosha:getCard(card_id)
		room:moveCardTo(card, from, sgs.Player_Hand, false)
		from:gainMark("truetuxi_count",1)

		room:setEmotion(to, "bad")
		room:setEmotion(from, "good")
	end,
}

truetuxi_viewas = sgs.CreateViewAsSkill
{--真＊突袭 视为技
	name = "truetuxi_viewas",	
	n = 0,
	
	view_as = function()
		return truetuxi_card:clone()		
	end,
	
	enabled_at_play = function()
		return false
	end,
	
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@truetuxi_main"
	end
}

truetuxi_main = sgs.CreateTriggerSkill
{--真＊突袭 主技能 触发技
	name = "truetuxi_main",
	view_as_skill = truetuxi_viewas,
	events = {sgs.PhaseChange},
	
	on_trigger = function(self, event, player, data)
		if(player:getPhase() == sgs.Player_Draw) then
			local room = player:getRoom()
			local can_invoke = false
			local other = room:getOtherPlayers(player)
			for _,aplayer in sgs.qlist(other) do
				if(not aplayer:isKongcheng()) then
					can_invoke = true
					break
				end
			end
			if(not room:askForSkillInvoke(player, "truetuxi_main")) then return false end
			if(can_invoke and room:askForUseCard(player, "@@truetuxi_main", "@truetuxi_card")) then return true end 
		return false end
		
		if (player:getPhase() == sgs.Player_Play) then
			if ( player:getMark("truetuxi_count") == 1 ) then player:drawCards(1) end
			local room = player:getRoom()
			room:setPlayerMark(player,"truetuxi_count",0)
		end
	end

}

true_zhangliao:addSkill(truetuxi_main)

sgs.LoadTranslationTable{
	["true_zhangliao"] = "真＊张辽",
	["#true_zhangliao"] = "前将军",
	["truetuxi_main"] = "真＊突袭",
	[":truetuxi_main"] = "摸牌阶段开始时，你可以放弃摸牌，改为获得一至两名角色的各一张手牌；若你只选择了一名角色，你将摸一张牌。",
	["@truetuxi_card"] = "您是否发动技能［真＊突袭］？",
	["~truetuxi_main"] = "选择 1-2 名角色——点击确定按钮。",
	["designer:true_zhangliao"] = "CL",
	["cv:true_zhangliao"] = "暂无",
	["illustrator:true_zhangliao"] = "暂无",
}

-- 拿破仑·波拿巴
-- CL：拿破仑的技能源自于我原来love扩展包的曹洪，感觉还是拿破仑适合这个技能一点，也是希望更加世界化。
-- 拿破仑统军有方，奈何滑铁卢一役在援军不确定的情况下率骑兵队突进，伤敌一万却也自损八千。
-- 称号：世之怪杰 源自周总理对拿破仑的评论。
	
napoleon = sgs.General(extension,"napoleon","wei",4)

luatongshuai=sgs.CreateTriggerSkill
{
	name="luatongshuai",
	events={sgs.CardResponsed,sgs.CardUsed},
	frequency = sgs.Skill_Frequent,

	on_trigger=function(self,event,player,data)
	local room=player:getRoom()	
	local selfplayer=room:findPlayerBySkillName(self:objectName())
	if not player:hasSkill("luatongshuai") then return false end
	local otherplayers=room:getOtherPlayers(selfplayer)
	if event==sgs.CardResponsed then
		local cd=data:toCard()
		if cd:inherits("BasicCard") then
			local room = player:getRoom()
			if not player:isAlive() then return false end
			if not room:askForSkillInvoke(player, "luatongshuai") then return false end
			room:playSkillEffect("luatongshuai", 1)
			player:drawCards(1)
			end
	end
	if event == sgs.CardUsed then
		local room = player:getRoom()
		local card = data:toCardUse().card
		if card:inherits("BasicCard") then 
			if not room:askForSkillInvoke(player, "luatongshuai") then return false end
			room:playSkillEffect("luatongshuai", 1)
			player:drawCards(1)
		end
	end
	end,

	can_trigger=function(self, player)
	local room=player:getRoom()
	local selfplayer=room:findPlayerBySkillName(self:objectName())
	if selfplayer==nil then return false end
	return selfplayer:isAlive()
	end,
}


luamaojin = sgs.CreateTriggerSkill
{
	name = "luamaojin",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageForseen},

	on_trigger = function(self,event,player,data)
		if not player:hasSkill("luamaojin") then return false end
		local damage = data:toDamage()
		local room = player:getRoom()
		local reason = damage.card
		if ( reason:inherits("Duel") ) or ( ( reason:inherits("Slash") )and ( reason:isRed() ) ) then
			damage.damage = damage.damage + 1
			data:setValue(damage)
			local log = sgs.LogMessage()
			log.type = "#luamaojin";
			log.from = player;
			log.arg = self:objectName();
			room:sendLog(log);
		end
		end,	
}
		
napoleon:addSkill(luatongshuai)
napoleon:addSkill(luamaojin)

sgs.LoadTranslationTable{
	["napoleon"] = "拿破仑·波拿巴",
	["#napoleon"] = "世之怪杰",
	["luatongshuai"] = "统帅",
	[":luatongshuai"] = "任何时候，每当你打出、使用一张基本牌，你可摸一张牌。",
	["luamaojin"] = "冒进",
	[":luamaojin"] = "锁定技，每当你受到红杀和决斗伤害时，该伤害加1。",
	["#luamaojin"] = "由于%from冒进无援，此伤害将加1。",
	["designer:napoleon"] = "CL",
	["cv:napoleon"] = "暂无",
	["illustrator:napoleon"] = "暂无",
}