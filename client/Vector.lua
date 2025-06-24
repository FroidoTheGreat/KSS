-- FIXME: make the mathematical operations directly reference the components instead of going
-- through the metamethods

local Vector = {}

function Vector.new(_, ...)
	local self = {}
	self.isVector = true

	self.components = {...}
	assert(#self.components > 0, "cannot make a vector with 0 components")

	if type(self.components[1]) == "table" then
		local ref = self.components[1]
		self.components = {}
		for _, v in ipairs(ref.components) do
			table.insert(self.components, v)
		end
	end
	self.length = #self.components

	for k, v in pairs(Vector) do
		if k ~= "new" and not self[k] and type(v) == "function" then
			self[k] = v
		end
	end

	setmetatable(self, Vector.imt)
	return self
end

function Vector:add(other)
	-- FIXME: make it work for numbers too
	assert(self.length == other.length, "cannot add vectors with different dimensions")
	assert(self.isVector and other.isVector, "attempt to perform vector addition on one or more non-vectors")
	local result = Vector(self)
	for i=1, self.length do
		result[i] = result[i] + other[i]
	end
	return result
end

function Vector:subtract(other)
	return self:add(-other)
end

function Vector:unaryMinus()
	local result = Vector(self)
	for i=1, result.length do
		result[i] = -result[i]
	end
	return result
end

function Vector:multiply(other)
	if type(self) == "number" then
		local interim = other
		other = self
		self = interim
	end
	if type(other) == "table" and other.isVector then
		assert(self.length == other.length)
		local result = 0
		for i=1, self.length do
			result = result + self[i] * other[i]
		end
		return result
	elseif type(other) == "number" then
		local result = Vector(self)
		for i=1, self.length do
			result[i] = result[i] * other
		end
		return result
	end
end

function Vector:divide(other)
	if type(self) == "number" then
		error("cannot divide a number by a vector")
	end
	return Vector(self) * (1 / other)
end

function Vector:magnitude()
	return math.sqrt(self:mag2())
end
function Vector:mag2()
	return self * self
end

function Vector:normal()
	return self / self:magnitude()
end

function Vector:equals(other, tolerance)
	if type(self) == "number" then
		local interim = other
		other = self
		self = interim
	end
	tolerance = tolerance or 0
	if type(other) == "table" and other.isVector then
		if self.length ~= other.length then
			return false
		end
		for i=1, self.length do
			if math.abs(self[i] - other[i]) < tolerance then
				return true
			end
		end
		return true
	elseif type(other) == "number" then
		return math.abs(self.magnitude - other) < tolerance
	else
		return false
	end
end

function Vector:lessThan(other)
	if type(self) == "number" then
		return self:greaterThanOrEqualTo(other, self)
	end
	if type(other) == "table" and other.isVector then
		return self:magnitude() < other:magnitude()
	elseif type(other) == "number" then
		return self:magnitude() < other
	else
		return false
	end
end

function Vector:greaterThan()
	if type(self) == "number" then
		return self:lessThanOrEqualTo(other, self)
	end
	if type(other) == "table" and other.isVector then
		return self:magnitude() > other:magnitude()
	elseif type(other) == "number" then
		return self:magnitude() > other
	else
		return false
	end
end

function Vector:lessThanOrEqualTo(other)
	if type(self) == "number" then
		return self:greaterThan(other, self)
	end
	if type(other) == "table" and other.isVector then
		return self:magnitude() <= other:magnitude()
	elseif type(other) == "number" then
		return self:magnitude() <= other
	else
		return false
	end
end

function Vector:greaterThanOrEqualTo(other)
	if type(self) == "number" then
		return self:lessThan(other, self)
	end
	if type(other) == "table" and other.isVector then
		return self:magnitude() >= other:magnitude()
	elseif type(other) == "number" then
		return self:magnitude() >= other
	else
		return false
	end
end

function Vector:toString()
	local s = "<"
	for i=1, self.length - 1 do
		s = s..self[i]..", "
	end
	if self.length > 0 then
		s = s..self[self.length]
	end
	return s..">"
end

Vector.mt = {
	__call = Vector.new,
}
setmetatable(Vector, Vector.mt)

Vector.imt = {
	__add = Vector.add,
	__div = Vector.divide,
	__sub = Vector.subtract,
	__unm = Vector.unaryMinus,
	__mul = Vector.multiply,
	__eq = Vector.equals,
	__lt = Vector.lessThan,
	__le = Vector.lessThanOrEqualTo,
	__index = function(self, key)
		if type(key) == "number" then
			return self.components[key]
		end
		if type(key) == "string" and #key == 1 then
			local i = string.find("xyzwijk", key)
			return self.components[i]
		elseif type(key) == "string" then
			return nil -- FIXME: implement syntax such as vector.xyxxy
		end
		return nil
	end,
	__newindex = function(self, key, value)
		if type(key) == "number" then
			self.components[key] = value
			return
		end
		if type(key) == "string" and #key == 1 then
			local i = string.find("xyzwijk", key)
			if i then
				self.components[i] = value
			end
			return
		end
		self[key] = value
	end,
	__tostring = Vector.toString,
}

return Vector