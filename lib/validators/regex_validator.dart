class RegexValidator{

  // RegExp nameRegExp = RegExp(r'^[a-zA-Z0-9 ]*$');
  RegExp nameRegExp = RegExp(r'^(?! )[a-zA-Z0-9.,]+(?: [a-zA-Z0-9.,]+)*$');
  
  RegExp studentNameRegExp = RegExp(r'^(?! )[a-zA-Z]+(?: [a-zA-Z]+)*$');
  // RegExp nameRegExp = RegExp(r'^[a-zA-Z]+(?:\s[a-zA-Z]+)*$');
  RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*@[a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*\.[a-zA-Z_-]{2,3}$');
  // RegExp passwordRegexp = RegExp(r'^(?=.*[A-Z])(?=.*[@#])[A-Za-z\d@#]{8,}$');
  RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$');
  // RegExp mobileRegExp = RegExp(r'^[0-9]{10}');
  RegExp mobileRegExp = RegExp(r'^[0-9]{10}');
  // Adhar
  RegExp aadharRegExp = RegExp(r'^[0-9]{12}');
  //Amount
  RegExp amountRegExp = RegExp(r'^[0-9]+$');

  //city,state validator
  RegExp cityRegexExp = RegExp(r"^[A-Za-z\s\-']+$");

  RegExp contentRegExp = RegExp(r'^(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}([\/\w\.-]*)*\/?$');

  // Name Regex
  // final nameRegex = RegExp(r'^[a-zA-Z](?!.*\s$)[a-zA-Z0-9\s]*[a-zA-Z0-9]$');
  // // Email Regex
  // final emailRegex = RegExp(r'^[a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*@[a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*\.[a-zA-Z_-]{2,3}$');
  // // Mobile Regex only 10 digit allow
  // RegExp mobileRegex = RegExp(r'^[0-9]{10}');
  // // Mobile Regex only 10 digit allow
  // RegExp aadharRegex = RegExp(r'^[0-9]{12}');

}