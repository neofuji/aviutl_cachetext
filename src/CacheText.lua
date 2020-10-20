-- CacheText $VERSION$ ( $GITHASH$ ) by oov
local P = {}
local Extram = require('Extram')

P.caches = {}

P.creating = false
P.beforekey = nil
P.key = nil
P.msg = nil

function P.del(key)
  if P.caches[key] ~= nil then
    for i = 0, P.caches[key].num do
      Extram.del(key .. "-" .. i)
    end
  end
  P.caches[key] = nil
end

-- message: ���b�Z�[�W�{��
-- mode: ���샂�[�h 0 = ��ɍŐV�f�[�^���g�� / 1 = �L���b�V�����g��
function P.mes(message, mode)
  -- �g���ҏW�� GUI ��œ��͂��ꂽ�e�L�X�g�� Shift_JIS �̑ʖڕ����ւ̑΍􂪍s���邪�A
  -- ����������������_�u���N�H�[�g�Ŋ����Ă��Ȃ��ꍇ�ɂ̓S�~�ɂȂ�̂ŏ������Ă���
  return P.rawmes(message:gsub("([\128-\160\224-\255]\092)\092","%1"), mode)
end

function P.rawmes(message, mode)
  P.gc()

  P.beforekey = nil
  P.key = "CacheText:" .. obj.layer
  P.msg = message
  local c = P.caches[P.key]
  if (c ~= nil and c.msg ~= P.msg)or(mode == 0) then
    -- �e�L�X�g���e���ς�������A�L���b�V���������[�h�Ȃ�L���b�V����j��
    P.del(P.key)
    c = nil
  end
  if c == nil then
    mes(P.msg)
    P.creating = true
  else
    mes("<s1,Arial>" .. string.rep(".", c.num))
    P.creating = false
  end
end

function P.after()
  if P.key ~= nil then
    if P.creating then
      P.store(P.key)
    else
      P.load(P.key)
    end
    P.beforekey = P.key
    P.key = nil
    return
  end
  if P.beforekey ~= nil and obj.index > 0 then
    if P.creating then
      P.store(P.beforekey)
    else
      P.load(P.beforekey)
    end
    return
  end
end

function P.store(key)
  -- �L���b�V���쐬
  local w, h = 0, 0
  if obj.w ~= 0 and obj.h ~= 0 then
    -- �摜�f�[�^�����肻���Ȃ�L���b�V���ɏ�������
    local data
    data, w, h = obj.getpixeldata()
    Extram.put(key .. "-" .. obj.index, data, w * 4 * h)
  end
  local c = P.caches[key]
  if obj.index == 0 then
    c = {
      t = os.clock(),
      d = 0,
      msg = P.msg,
      num = obj.num,
      img = {},
    }
  end
  c.img[obj.index] = {
    w = w,
    h = h,
    ox = obj.ox,
    oy = obj.oy,
    oz = obj.oz,
    rx = obj.rx,
    ry = obj.ry,
    rz = obj.rz,
    cx = obj.cx,
    cy = obj.cy,
    cz = obj.cz,
    zoom = obj.zoom,
    alpha = obj.alpha,
    aspect = obj.aspect,
  }
  P.caches[key] = c
end

function P.load(key)
  local c = P.caches[key]
  if c ~= nil and c.num ~= obj.num then
    -- �L���b�V���L�����Ɂu�������ɌʃI�u�W�F�N�g�v�̃`�F�b�N���؂�ւ���ꂽ
    -- �摜�̖������ς�邪����̓e�L�X�g���`�悳��Ă��Ȃ��̂Œ��߂邵���Ȃ�
    P.del(key)
    P.beforekey = nil
    P.key = nil
    return
  end
  if c == nil then
    error("invalid internal state")
  end
  if obj.index == 0 then
    c.t = os.clock()
    c.d = 0
  end
  local cimg = c.img[obj.index]
  if cimg.w == 0 or cimg.h == 0 then
    -- �`�悷��K�v���Ȃ�����
    return
  end
  obj.setoption("drawtarget", "tempbuffer", cimg.w, cimg.h)
  obj.load("tempbuffer")
  local data, w, h = obj.getpixeldata()
  if not pcall(Extram.get, key .. "-" .. obj.index, data, w * 4 * h) then
    -- �L���b�V������̓ǂݍ��݂Ɏ��s�����ꍇ�͒��߂�i�蓮�ŏ����ꂽ�ꍇ�Ȃǁj
    return
  end
  obj.putpixeldata(data)
  obj.ox = cimg.ox
  obj.oy = cimg.oy
  obj.oz = cimg.oz
  obj.rx = cimg.rx
  obj.ry = cimg.ry
  obj.rz = cimg.rz
  obj.cx = cimg.cx
  obj.cy = cimg.cy
  obj.cz = cimg.cz
  obj.zoom = cimg.zoom
  obj.alpha = cimg.alpha
  obj.aspect = cimg.aspect
end

P.lifetime = 3 -- �b
P.gcinterval = 10 -- �b
P.lastgc = 0
function P.gc()
  local t = os.clock()
  if P.lastgc + P.gcinterval >= t then
    -- �܂�����܂莞�Ԃ��o���ĂȂ�
    return
  end
  for key, c in pairs(P.caches) do
    if c.t + P.lifetime < t then
      -- �ŋߎg���Ă��Ȃ��f�[�^�𔭌�
      if c.d == 0 then
        c.d = 1 -- �폜�ΏۂƂ��ă}�[�N
      else
        P.del(key) -- ���ۂɍ폜
      end
    end
  end
  P.lastgc = os.clock()
end

return P
