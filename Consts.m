classdef Consts
    
	properties(Constant)
		DEVICE_WIDTH_PIXEL = 1080;
		DEVICE_HEIGHT_PIXEL = 1920;
		CAPACITY_BLOCK_X_NUM = 16;
		CAPACITY_BLOCK_Y_NUM = 28;
		TOTAL_BLOCK_SIZE = Consts.CAPACITY_BLOCK_X_NUM * Consts.CAPACITY_BLOCK_Y_NUM;
		BLOCK_WIDTH = floor(Consts.DEVICE_WIDTH_PIXEL / Consts.CAPACITY_BLOCK_X_NUM);
		BLOCK_HEIGHT = floor(Consts.DEVICE_HEIGHT_PIXEL / Consts.CAPACITY_BLOCK_Y_NUM);
        AREA_CAPACITY_THRESHOLD = 50;
        CONNECTED_AREA_LARGEST_TIME_OFFSET = 25; % 本来是20  发现一个插了帧之后超过20的
        MAX_UNREPORTED_TIME = 30;
        
        SLIDE = 1;
        DRAG = 2;
        CLICK = 3;
        FORCE_CLICK = 4;
        UNKNOWN = 5;
        
        FRAME_STROE_SIZE = 3;
        BE_SLIDE_RATIO = 0.6;
	end
end