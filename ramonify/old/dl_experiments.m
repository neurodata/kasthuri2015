%% From Mike 1031

oo = OCP();
oo.setServerLocation('http://openconnecto.me')
oo.setAnnoToken('deep_learning2015');
oo.setAnnoChannel('inpainted90_N3_10312015');

for i = 1:256
    i
    m = RAMONVolume;
    m.setXyzOffset([5472,8712,1000+i-1]);
    
    m.setResolution(1);
    
    temp = imread('/Users/graywr1/Downloads/kast_inpainted_256.tif',i);
    temp = 1-(single(temp)/255);%temp = temp(end:-1:1,end:-1:1);
    m.setDataType(eRAMONChannelDataType.float32);
    m.setChannel('inpainted90_N3_10312015');
    m.setChannelType(eRAMONChannelType.image);
    m.setCutout(temp);
    oo.createAnnotation(m)
end