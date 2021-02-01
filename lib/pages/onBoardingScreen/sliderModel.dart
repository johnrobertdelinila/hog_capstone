class SliderModel{
  String title;
  String desc;
  String imageAssetPath;

  SliderModel({this.title, this.desc});

  void setTitle(String getTitle){
    title = getTitle;
  }

  void setImageAssetPath(String getImageAssetPath){
    imageAssetPath = getImageAssetPath;
  }

  void setDesc(String getDesc){
    desc = getDesc;
  }

  String getImageAssetPath(){
    return imageAssetPath;
  }

  String getTitle(){
    return title;
  }

  String getDesc(){
    return desc;
  }
}

List<SliderModel> getSlides(){
  List<SliderModel> slides = new List<SliderModel>();
  SliderModel sliderModel = new SliderModel();

  sliderModel.setTitle('Hog Mart');
  sliderModel.setDesc('Welcome to Hog Mart! Buy our Hogs easily and get access to app only exclusives.');
  sliderModel.setImageAssetPath('assets/pigIcon.png');
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  sliderModel.setTitle('Quality Hog');
  sliderModel.setDesc('Add Hog to your hog cart, and buy them out later.' );
  sliderModel.setImageAssetPath('assets/onBoarding/quality-pigs.jpg');
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  sliderModel.setTitle('QR Scan');
  sliderModel.setDesc('Search among variety of Hogs using the QR Code scan. The choice is yours.');
  sliderModel.setImageAssetPath('assets/onBoarding/qr-code.jpg');
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  sliderModel.setTitle('Make the Payment');
  sliderModel.setDesc('Choose preferable option of payment');
  sliderModel.setImageAssetPath('assets/onBoarding/payment-square.jpg');
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  sliderModel.setTitle('Delivery');
  sliderModel.setDesc('Super, fast and reliable delivery');
  sliderModel.setImageAssetPath('assets/onBoarding/pig-delivery.jpg');
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  sliderModel.setTitle('Customer Satisfaction');
  sliderModel.setDesc('Get high quality hogs for the best prices');
  sliderModel.setImageAssetPath('assets/onBoarding/premium-quality.png');
  slides.add(sliderModel);

  return slides;
}