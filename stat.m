load res.mat
totalSize = length(res(:, 1));
slide = [];
click = [];
SLIDE = 1;
DRAG = 2;
CLICK = 3;
FORCE_CLICK = 4;
UNKNOWN = 5;

slide = res(find((res(:, 3) == SLIDE | res(:, 3) == DRAG) == 1), 1:2);
click = res(find((res(:, 3) == CLICK | res(:, 3) == FORCE_CLICK) == 1), 1:2);

ratio = length(slide) / length(click);


max_X = 10000;%for pos
max_Y = 10000;%for neg
step = 500;
size_X = ceil(max_X / step);
size_Y = ceil(max_Y / step);
Click_M = zeros(size_X, size_Y);
Slide_M = zeros(size_X, size_Y);
for i = 1: length(click)
    x = click(i, 1);
    y = click(i, 2);
    if(x <= 0 || y >= 0)
        continue;
    end
    x = ceil(abs(x / step));
    y = ceil(abs(y / step));
    if(x <= size_X && y <= size_Y)
        Click_M(x, y) = Click_M(x, y) + 1; 
    end
end
Click_M = Click_M * ratio;

for i = 1: length(slide)
    
    x = slide(i, 1);
    y = slide(i, 2);
    if(x <= 0 || y >= 0)
        continue;
    end
    x = ceil(abs(x / step));
    y = ceil(abs(y / step));
    if(x <= size_X && y <= size_Y)
        Slide_M(x, y) = Slide_M(x, y) + 1; 
    end
end
Poss_train = (Slide_M + 0.01) ./ (Click_M + Slide_M + 0.02);
for i= 1: 1
    Poss_DOWN = [Poss_train(1,:); Poss_train(1:end-1, :)];
    Poss_UP = [Poss_train(2:end, :); Poss_train(end,:)];
    Poss_LEFT = [Poss_train(:, 2:end), Poss_train(:, end)];
    Poss_RIGHT = [Poss_train(:, 1), Poss_train(:, 1: end - 1)];
    Poss_SMOOTH = (Poss_train + Poss_DOWN + Poss_UP + Poss_LEFT + Poss_RIGHT) / 5;
    Poss_train = Poss_SMOOTH;
end

img = imshow(Poss_SMOOTH','InitialMagnification','fit');
save('./ClassifierPara/Poss_SMOOTH.mat', 'Poss_SMOOTH');
save('./ClassifierPara/step.mat', 'step');
save('./ClassifierPara/max_X.mat', 'max_X');
save('./ClassifierPara/max_y.mat', 'max_Y');