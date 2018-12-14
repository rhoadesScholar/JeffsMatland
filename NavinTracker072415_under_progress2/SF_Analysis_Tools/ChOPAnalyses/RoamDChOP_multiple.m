[ChOPDetails1 ConDetails1 estTR estE] = RoamsDuringChOP(allRIFAIY,900,960);
[ChOPDetails2 ConDetails2 estTR estE] = RoamsDuringChOP(allRIFAIY,1920,1980);
[ChOPDetails3 ConDetails3 estTR estE] = RoamsDuringChOP(allRIFAIY,2940,3000);
[ChOPDetails4 ConDetails4 estTR estE] = RoamsDuringChOP(allRIFAIY,3960,4020);
[ChOPDetails5 ConDetails5 estTR estE] = RoamsDuringChOP(allRIFAIY,4980,5040);
[ChOPDetails6 ConDetails6 estTR estE] = RoamsDuringChOP(allRIFAIY,6000,6060);
AllChOP = [ChOPDetails1; ChOPDetails2; ChOPDetails3; ChOPDetails4; ChOPDetails5; ChOPDetails6];
AllCon = [ConDetails1; ConDetails2; ConDetails3; ConDetails4; ConDetails5; ConDetails6;];

