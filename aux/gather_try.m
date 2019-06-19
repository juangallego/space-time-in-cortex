%
% Try gathering data matrix. Useful for code that can parametically use or
% not use a GPU
%

function x = gather_try(x)

try
    x = gather(x);
catch
end