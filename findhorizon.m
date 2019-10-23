function [fhorizon, horizon] = findhorizon(BW2,nrvp,ncpsi)
horizon = zeros(ncpsi,1); % Create array of all zeros(480,1) ncpsi = column 
fhorizon = false;
for k = 1:nrvp
    kr = k; kc = 1; horizon(1,:) = kr; %horizon(1,:)= gives 1st row 
    while true
        if (kc == ncpsi)
            fhorizon = true;
            break;
        elseif BW2(kr,kc+1)
            kc = kc+1;
        elseif (kr>1) && BW2(kr-1,kc+1)
            kr = kr-1; kc = kc+1;
        elseif (kr<nrvp) && BW2(kr+1,kc+1)
            kr = kr+1; kc = kc+1;
        else
            break;
        end
        horizon(kc) = kr;
    end
    if fhorizon
        break;
    end
end