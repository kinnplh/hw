load res.mat
totalSize = length(res(:, 1));
SLIDE = 1;
DRAG = 2;
CLICK = 3;
FORCE_CLICK = 4;
UNKNOWN = 5;

slide = res((res(:, 3) == SLIDE | res(:, 3) == DRAG) == 1, 1:2);
click = res((res(:, 3) == CLICK | res(:, 3) == FORCE_CLICK) == 1, 1:2);


slide = slide((slide(:, 1) > 0 & (slide(:, 2) < 0)) == 1, 1:2);
click = click((click(:, 1) > 0 & (click(:, 2) < 0)) == 1, 1:2);

slideRatio = abs(slide(:, 1) ./ slide(:, 2));
clickRatio = abs(click(:, 1) ./ click(:, 2));