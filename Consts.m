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
        CONNECTED_AREA_LARGEST_TIME_OFFSET = 20;
        
        SLIDE = 1;
        CLICK = 2;
        UNKNOWN = 3;
        
        FRAME_STROE_SIZE = 3;
	end
end