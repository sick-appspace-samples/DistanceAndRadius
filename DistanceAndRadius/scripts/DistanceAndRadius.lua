--[[----------------------------------------------------------------------------

  Application Name:
  DistanceAndRadius
                                                                                             
  Summary:
  Fitting two edges, measuring their shortest (orthogonal) distance and fitting a circle,
  measuring its radius and distance to a third edge.
  
  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  Restarting the Sample may be necessary to show images after loading the webpage.
  To run this Sample a device with SICK Algorithm API and AppEngine >= V2.5.0 is
  required. For example SIM4000 with latest firmware. Alternatively the Emulator
  in AppStudio 2.3 or higher can be used.
       
  More Information:
  Tutorial "Algorithms - Fitting and Measurement".
  
------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

print('AppEngine Version: ' .. Engine.getVersion())

local DELAY = 1000 -- ms between visualization steps for demonstration purpose

-- Creating viewer
local viewer = View.create()

-- Setup graphical overlay attributes
local regionDecoration = View.ShapeDecoration.create()
regionDecoration:setLineColor(230, 230, 0) -- Yellow
regionDecoration:setLineWidth(4)

local featureDecoration = View.ShapeDecoration.create()
featureDecoration:setLineColor(75, 75, 255) -- Blue
featureDecoration:setLineWidth(4)
featureDecoration:setPointType('DOT')
featureDecoration:setPointSize(5)

local dotDecoration = View.ShapeDecoration.create()
dotDecoration:setLineColor(230, 0, 0) -- Red
dotDecoration:setPointType('DOT')
dotDecoration:setPointSize(10)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

--@addText(x:int, y:int, txtString:string)
local function addText(x, y, txtString, imageID)
  local deco = View.TextDecoration.create()
  deco:setSize(20)
  deco:setPosition(x, y)
  viewer:addText(txtString, deco, nil, imageID)
end

local function main()
  viewer:clear()
  local img = Image.load('resources/DistanceAndRadius.bmp')
  local imageID = viewer:addImage(img)
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

  viewer:addShape(outerCircle, regionDecoration, nil, imageID)
  viewer:addShape(foundCircle, featureDecoration, nil, imageID)
  viewer:addShape(foundCircle:getCenterOfGravity(), dotDecoration, nil, imageID)

  -- Fitting edge1 (left)
  local edgeCenter1 = Point.create(113, 260)
  local edgeRect1 = Shape.createRectangle(edgeCenter1, 40, 80, 0)
  local angle1 = 0
  local edge1segm, _ = fitter:fitLine(img, edgeRect1:toPixelRegion(img), angle1)
  viewer:addShape(edge1segm, featureDecoration, nil, imageID)
  viewer:addShape(edgeRect1, regionDecoration, nil, imageID)

  -- Fitting edge2 (right)
  local edgeCenter2 = Point.create(515, 300)
  local edgeRect2 = Shape.createRectangle(edgeCenter2, 40, 150, 0)
  local angle2 = math.pi -- pi rad = 180 deg
  local edge2segm, _ = fitter:fitLine(img, edgeRect2:toPixelRegion(img), angle2)
  local line2 = edge2segm:toLine()
  viewer:addShape(edge2segm, featureDecoration, nil, imageID)
  viewer:addShape(edgeRect2, regionDecoration, nil, imageID)

  -- Fitting edge3 (bottom)
  local edgeCenter3 = Point.create(250, 396)
  local edgeRect3 = Shape.createRectangle(edgeCenter3, 150, 40, 0)
  local angle3 = -math.pi / 2 --  -pi/2 rad = -90 deg
  local edge3segm,  _ = fitter:fitLine(img, edgeRect3:toPixelRegion(img), angle3)
  local line3 = edge3segm:toLine()
  viewer:addShape(edge3segm, featureDecoration, nil, imageID)
  viewer:addShape(edgeRect3, regionDecoration, nil, imageID)

  -- Measuring radius
  local radius = math.floor(foundCircle:getRadius() * 10) / 10
  local posX = circleCenter:getX() + outerRadius + 10
  local posY = circleCenter:getY() - 13
  addText(posX, posY, 'r = ' .. radius, imageID)

  -- Measuring shortest edge-to-edge distance (orthogonal point-to-line)
  local midpoint = edge1segm:getCenterOfGravity()
  local closestPoint1 = line2:getClosestContourPoint(midpoint)
  local distance1 = math.floor(midpoint:getDistance(closestPoint1) * 10) / 10
  local distLine1 = Shape.createLineSegment(midpoint, closestPoint1)

  viewer:addShape(distLine1, featureDecoration, nil, imageID)
  addText(247, 225, 'd1 = ' .. distance1, imageID)

  -- Measuring shortest circle center to line distance (orthogonal point-to-line)
  local closestPoint2 = line3:getClosestContourPoint(circleCenter)
  local distance2 = math.floor(circleCenter:getDistance(closestPoint2) * 10) / 10
  local distLine2 = Shape.createLineSegment(circleCenter, closestPoint2)
  viewer:addShape(distLine2, featureDecoration, nil, imageID)
  addText(330, 350, 'd2 = ' .. distance2, imageID)
  viewer:present()

  print('d1 = ' .. distance1 .. ' d2 = ' .. distance2 .. ' r = ' .. radius)
  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
