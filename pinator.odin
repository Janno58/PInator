package main

import "core:fmt"
import "core:math/rand"
import "core:math"
import "core:strings"
import "core:strconv"
import "vendor:raylib"

IntRect :: struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
}

Pixel :: struct {
    x: i32,
    y: i32,
}

length :: proc(x: i32, y: i32) -> i32 {
    len: f64 = f64((x*x) + (y*y));
    return i32(math.sqrt(len))
}

isInside :: proc(x: i32, y: i32, rect: IntRect) -> bool {
    return x >= rect.x && x <= rect.x + rect.width \
	&& y >= rect.y && y <= rect.y + rect.height;
}

drawButton :: proc(rect: IntRect, text: cstring, invert: bool) {
    if(invert) {
	raylib.DrawRectangle(rect.x, rect.y, rect.width, rect.height, raylib.BLACK)
	raylib.DrawText(text, rect.x+20, rect.y+5, 26, raylib.WHITE)
    } else {
	raylib.DrawRectangleLines(rect.x, rect.y, rect.width, rect.height, raylib.BLACK)
	raylib.DrawText(text, rect.x+20, rect.y+5, 26, raylib.BLACK)
    }
}

addDot :: proc(pixels: ^[dynamic]Pixel, radius: i32, count: i32 = 1) -> (i32, i32) {
    inside: i32
    outside: i32

    for i: i32 = 0; i < count; i += 1 {
	randNr: i32 = rand.int31_max(radius*radius*4);
	y: i32 = randNr / (radius+radius)
	x: i32 = randNr % (radius+radius)

	append(pixels, Pixel{x, y})

	if(length(x - radius, y - radius) < radius) {
	    inside += 1
	} else {
	    outside += 1
	}
    }

    return inside, outside
}

main :: proc() {
    winWidth: i32 = 1024
    winHeight: i32 = 768

    raylib.InitWindow(winWidth, winHeight, "Title")
    raylib.SetTargetFPS(165)
   
    pixels: [dynamic]Pixel
    insideCount: i32
    outsideCount: i32

    camera: raylib.Camera2D
    camera.zoom = 2.0
    camera.target.x = 320 
    camera.target.y = 200

    PI: f64 = 0.0

    for !raylib.WindowShouldClose() {
	raylib.BeginDrawing();
	raylib.ClearBackground(raylib.WHITE)
	
	if(insideCount + outsideCount > 0) {
	    PI = 4.0 * f64(insideCount) / f64(insideCount + outsideCount)
	}
	buf: strings.Builder
	strings.write_f64(&buf, PI, 'f')
	raylib.DrawText(strings.to_cstring(&buf), 200, 60, 32, raylib.RED);

	raylib.BeginMode2D(camera);

	radius: i32 = 100
	xPos: i32 = winWidth / 2 - radius 
	yPos: i32 = winHeight / 2 - radius 
	raylib.DrawRectangleLines(xPos, yPos, radius*2, radius*2, raylib.BLACK)

	xCenter: i32 = winWidth / 2
	yCenter: i32 = winHeight / 2
	raylib.DrawCircleLines(xCenter, yCenter, f32(radius), raylib.BLACK)
	
	for pixel in pixels {
	    raylib.DrawPixel(xPos + pixel.x, yPos + pixel.y, raylib.RED);
	}

	raylib.EndMode2D();
	
	mouseX: i32 = i32(raylib.GetMouseX())
	mouseY: i32 = i32(raylib.GetMouseY())

	addButRect: IntRect = {xPos + radius*2 + 50, yPos, 180, 40}; 
	add1kButRect: IntRect = {xPos + radius*2 + 50, yPos + 50, 180, 40}; 
	clearButRect: IntRect = {xPos + radius*2 + 50, yPos + 100, 180, 40}; 

	addHovered: bool = isInside(mouseX, mouseY, addButRect)
	add1kHovered: bool = isInside(mouseX, mouseY, add1kButRect)
	clearHovered: bool = isInside(mouseX, mouseY, clearButRect)
	
	drawButton(addButRect, "Add dot", addHovered)
	drawButton(add1kButRect, "Add 1K dots", add1kHovered)
	drawButton(clearButRect, "Clear", clearHovered)

	if(addHovered && raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT)) {
	    inside, outside := addDot(&pixels, radius, 1)
	    insideCount += inside
	    outsideCount += outside
	}
	else if(add1kHovered && raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT)) {
	    inside, outside := addDot(&pixels, radius, 1000)
	    insideCount += inside
	    outsideCount += outside
	}
	else if(clearHovered && raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT)) {
		clear(&pixels)
		insideCount = 0
		outsideCount = 0
	}	

	raylib.EndDrawing();
    }
    
    raylib.CloseWindow();
}
