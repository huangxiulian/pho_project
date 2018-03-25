-- 跑胡子计算的公共函数
PHZPlayFunc = {}

local POKER_VALUE = {
	["1"] = 1,["2"] = 2,["3"] = 3, ["4"] = 4,["5"] = 5,
	["6"] = 6, ["7"] = 7,["8"] = 8,["9"] = 9, ["T"] = 10,
}

--[[
    可吃的牌组合表结构 tTab.ntype ,"addone"连着，"addtwo" 隔一个 tTab.fircardstr 第一张牌字符串eg:1b
     tTab.fircardnum 第一牌数字 1-10 小写  11-20大写 tTab.lastcardstr  另一张牌字符串

    其他表结构  temp.count = 数量  temp.cardnum = cardValue 牌数字
        temp.cardstr = v  牌字符串
]]
function PHZPlayFunc:initData()
    self._pengCards = {}    --可碰或绞的牌  手里2张
    self._chiCards = {}     --可以吃的牌  连着或间隔1
    self._gangCards = {}    --可跑或提的牌  手里3张
    self._firstGang = {}    --一开始要提的牌  手里四张
    self._onlyOneCards = {}   --没有组合的单牌
    self._handCards = {}    --手中还未出的牌
    self._outCards = {}     --已经打出的组合牌
    local testData = {"1a","2a","2a","2a","2a","3a","4a","6a","8a","8a","9a","9a","Ta","1b","1b","4b","5b","7b","9b","9b","Tb","Tb","Tb"}
    self:setCardsCompose(testData)
    for i,v in ipairs(self._chiCards) do 
        -- print(v.cardstr,v.cardnum.."    dddddddddddddddddddddddddd")        
        print(v.ntype,v.fircardnum,v.fircardstr,v.lastcardstr.."    dddddddddddddddddddddddddd")
    end
    local pengCard = self:getHandChiCards("5a")
    if pengCard then
        -- print(pengCard.cardstr.."  bbbbbbbbbbbbbb")
        for i,v in ipairs(pengCard) do
            print(v.fircardstr,v.lastcardstr.."  bbbbbbbbbbbbbbb")
        end
    end
end


--初始化手牌所有组合 
function PHZPlayFunc:setCardsCompose(cardsInfo)
    local temp = {}
    for i,v in ipairs(cardsInfo or {}) do
        local num = string.sub(v , 1, 1)
        local cType = string.sub(v , 2 , 2)
        -- print(num,cType.."  fffffffffffffff")
        local cardValue = POKER_VALUE[num]
        if cType == "b" then
            cardValue = cardValue + 10
        end
        if not temp[cardValue] then
            temp[cardValue] = {}
            temp[cardValue].count = 0
            temp[cardValue].cardnum = cardValue
        end
        temp[cardValue].count = temp[cardValue].count + 1
        temp[cardValue].cardstr = v
    end
    for i,v in pairs(temp or {}) do
        --吃
        if v.count == 1 or v.count == 2 then
            if v.cardnum ~= 10 then
                -- print(v.cardnum.."  pppppppppppppp")
                if temp[v.cardnum + 1] and temp[v.cardnum + 1].count <= 2 then
                    local tTab = {}
                    tTab.ntype = "addone"
                    tTab.fircardstr = v.cardstr
                    tTab.lastcardstr = temp[v.cardnum + 1].cardstr                    
                    tTab.fircardnum = v.cardnum
                    table.insert(self._chiCards,tTab)
                end
                if temp[v.cardnum + 2] and temp[v.cardnum + 2].count <= 2 then
                    if temp[v.cardnum + 1] and temp[v.cardnum + 1].count == 4 then
                    else
                        local tTab = {}
                        tTab.ntype = "addtwo"
                        tTab.fircardstr = v.cardstr
                        tTab.lastcardstr = temp[v.cardnum + 2].cardstr
                        tTab.fircardnum = v.cardnum
                        table.insert(self._chiCards,tTab)
                    end
                end
            end
        end
        if v.count == 1 then
            if (not temp[v.cardnum + 1] and not temp[v.cardnum + 2] and not temp[v.cardnum - 1] and not temp[v.cardnum - 2]) or (temp[v.cardnum + 1] and temp[v.cardnum + 1].count > 2) then
                table.insert(self._onlyOneCards,v)              
            end
        end
        --碰或偎
        if v.count == 2 then
            table.insert(self._pengCards,v)
        end
        --跑或提
        if v.count == 3 then
            table.insert(self._gangCards,v)
        end
        --提
        if v.count == 4 then
            table.insert(self._firstGang,v)
        end
    end
end

--设置成打出的牌
function PHZPlayFunc:setOutCards(outCards)
    
end

--获取手上能碰的牌组合
function PHZPlayFunc:getHandPengCards(compareCard)
    for i,v in ipairs(self._pengCards) do
        if v.cardstr == compareCard then
            return v
        end
    end
    return nil
end

--获取手上能吃的牌组合
function PHZPlayFunc:getHandChiCards(compareCard)
    local cNum = string.sub(compareCard or "",1,1)
    local cType = string.sub(compareCard or "",2,2)
    local cValue = POKER_VALUE[cNum]   
    if not cValue then
        return 
    end 
    if cType == "b" then
        cValue = cValue + 10
    end
    local reChiList = {}
    for i,v in ipairs(self._chiCards) do        
        if v.ntype == "addone" then
            if (cValue == v.fircardnum - 1) or  (cValue == v.fircardnum + 2) then
                table.insert(reChiList,v)
            end
        elseif v.ntype == "addtwo" then
            if (cValue == v.fircardnum + 1) then
                table.insert(reChiList,v)                
            end
        end
    end
    return reChiList
end

--获取手上能提或跑的牌组合
function PHZPlayFunc:getHandGangCards(compareCard)
    for i,v in ipairs(self._gangCards) do
        if v.cardstr == compareCard then
            return v
        end
    end
    return nil
end

--获取手牌能提的的牌组合
function PHZPlayFunc:getHandFirGangCards(compareCard)
    for i,v in ipairs(self._firstGang) do
        if v.cardstr == compareCard then
            return v
        end
    end
    return nil
end

--获取手上能绞的牌组合
function PHZPlayFunc:getHandChiCards(compareCard)
    local cNum = string.sub(compareCard or "",1,1)
    local cType = string.sub(compareCard or "",2,2)
    
    if cType == "b" then
        compareCard = cNum.."a"
    else
        compareCard = cNum.."b"
    end

    for i,v in ipairs(self._pengCards) do
        if v.cardstr == compareCard then
            return v
        end
    end

    return nil
end

