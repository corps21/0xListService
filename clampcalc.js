
/*To use responsive typography*/


const pixeltoRem = (pixel) => pixel / 16 ;
const remToPixel = (rem) => rem * 16;

const minFontSize = 1.05; // font size in rem default value: 2.25
const maxFontSize = 1.50; // font size in rem default value: 3.25
const minViewPort = 801; // view port in px default value: 600
const maxviewPort = 1600; // view port in px default value: 1400

const resultvw = (100 * (remToPixel(maxFontSize) - remToPixel(minFontSize))) / (maxviewPort - minViewPort) 

const resultMain = ((minViewPort * remToPixel(maxFontSize)) - (maxviewPort * remToPixel(minFontSize))) / (minViewPort - maxviewPort);


console.log(`clamp(${minFontSize}rem, ${resultvw.toFixed(4)}vw + ${pixeltoRem(resultMain).toFixed(4)}rem ,${maxFontSize}rem);`)
// default result : clamp(2.25rem, 2vw + 1.5rem ,3.25rem);

