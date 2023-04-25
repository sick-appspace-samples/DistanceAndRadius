
--Start of Global Scope---------------------------------------------------------

print('AppEngine Version: ' .. Engine.getVersion())

local DELAY = 1000 -- ms between visualization steps for demonstration purpose

-- Creating viewer
local viewer = View.create()

-- Setup graphical overlay attributes
local regionDecoration = View.ShapeDecoration.create():setLineWidth(4)
regionDecoration:setLineColor(230, 230, 0) -- Yellow

local featureDecoration = View.ShapeDecoration.create():setLineWidth(4)
featureDecoration:setLineColor(75, 75, 255) -- Blue
featureDecoration:setPointType('DOT'):setPointSize(5)

local dotDecoration = View.ShapeDecoration.create():setPointSize(10)
dotDecoration:setPointType('DOT'):setLineColor(230, 0, 0) -- Red

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

---@param x int
---@param y int
---@param txtString string
local function addText(x, y, txtString)
  local deco = View.TextDecoration.create()
  deco:setSize(20)
  deco:setPosition(x, y)
  viewer:addText(txtString, deco)
end

local function main()
  viewer:clear()
  local img = Image.load('resources/DistanceAndRadius.bmp')
  viewer:addImage(img)
  viewer:present()
  Script.sleep(DELAY) -- for demonstration purpose only

  -- Creating common fitter
  local fitter = Image.ShapeFitter.create()
  fitter:setProbeCount(25)

  -- Fitting circle
  local circleCenter = Point.create(312, 307)
  local outerRadius = 40
  local outerCircle = Shape.createCircle(circleCenter, outerRadius)
  local innerRadius = 10
  local foundCircle, _ = fitter:fitCircle(img, outerCircle, innerRadius)

  viewer:addShape(outerCircle, regionDecoration)
  viewer:addShape(foundCircle, featureDecoration)
  viewer:addShape(foundCircle:getCenterOfGravity(), dotDecoration, nil)

  -- Fitting edge1 (left)
  local edgeCenter1 = Point.create(113, 260)
  local edgeRect1 = Shape.createRectangle(edgeCenter1, 40, 80, 0)
  local angle1 = 0
  local edge1segm, _ = fitter:fitLine(img, edgeRect1:toPixelRegion(img), angle1)
  viewer:addShape(edge1segm, featureDecoration)
  viewer:addShape(edgeRect1, regionDecoration)

  -- Fitting edge2 (right)
  local edgeCenter2 = Point.create(515, 300)
  local edgeRect2 = Shape.createRectangle(edgeCenter2, 40, 150, 0)
  local angle2 = math.pi -- pi rad = 180 deg
  local edge2segm, _ = fitter:fitLine(img, edgeRect2:toPixelRegion(img), angle2)
  local line2 = edge2segm:toLine()
  viewer:addShape(edge2segm, featureDecoration)
  viewer:addShape(edgeRect2, regionDecoration)

  -- Fitting edge3 (bottom)
  local edgeCenter3 = Point.create(250, 396)
  local edgeRect3 = Shape.createRectangle(edgeCenter3, 150, 40, 0)
  local angle3 = -math.pi / 2 --  -pi/2 rad = -90 deg
  local edge3segm,  _ = fitter:fitLine(img, edgeRect3:toPixelRegion(img), angle3)
  local line3 = edge3segm:toLine()
  viewer:addShape(edge3segm, featureDecoration)
  viewer:addShape(edgeRect3, regionDecoration)

  -- Measuring radius
  local _ ,radius = foundCircle:getCircleParameters()
  local posX = circleCenter:getX() + outerRadius + 10
  local posY = circleCenter:getY() - 13
  addText(posX, posY, 'r = ' .. radius)

  -- Measuring shortest edge-to-edge distance (orthogonal point-to-line)
  local midpoint = edge1segm:getCenterOfGravity()
  local closestPoint1 = line2:getClosestContourPoint(midpoint)
  local distance1 = math.floor(midpoint:getDistance(closestPoint1) * 10) / 10
  local distLine1 = Shape.createLineSegment(midpoint, closestPoint1)

  viewer:addShape(distLine1, featureDecoration)
  addText(247, 225, 'd1 = ' .. distance1)

  -- Measuring shortest circle center to line distance (orthogonal point-to-line)
  local closestPoint2 = line3:getClosestContourPoint(circleCenter)
  local distance2 = math.floor(circleCenter:getDistance(closestPoint2) * 10) / 10
  local distLine2 = Shape.createLineSegment(circleCenter, closestPoint2)
  viewer:addShape(distLine2, featureDecoration)
  addText(330, 350, 'd2 = ' .. distance2)
  viewer:present()

  print('d1 = ' .. distance1 .. ' d2 = ' .. distance2 .. ' r = ' .. radius)
  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
