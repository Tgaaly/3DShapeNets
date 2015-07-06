function [ gOrb ] = checkKey( )

    w=0;
    while w==0 
        w=waitforbuttonpress;
    end
    
    k=get(gcf,'CurrentCharacter');
    if k=='g' 
        gOrb=1;
    elseif k=='b'
        gOrb=0;
    end

end

