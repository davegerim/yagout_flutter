import 'dart:convert';
import 'lib/utils/crypto/aes_util.dart';

void main() async {
  print('=== Testing YagoutPay Encryption ===\n');

  // Test credentials from documentation
  const testKey = '6eUzH0ZdoVVBMTHrgdA0sqOFyKm54zojV4/faiSirkE=';
  const testMeId = '202505090001';

  print('Test Key: $testKey');
  print('Test Merchant ID: $testMeId\n');

  // Test 1: Simple data encryption/decryption
  print('1. Testing simple encryption/decryption...');
  final testData = {'me_id': testMeId, 'amount': '100'};
  final plainText = jsonEncode(testData);

  print('Plain text: $plainText');

  try {
    final encrypted = AesUtil.encryptToBase64(plainText, testKey);
    print('Encrypted: $encrypted');

    final decrypted = AesUtil.decryptFromBase64(encrypted, testKey);
    print('Decrypted: $decrypted');

    if (decrypted == plainText) {
      print('✅ Simple encryption/decryption: SUCCESS\n');
    } else {
      print('❌ Simple encryption/decryption: FAILED\n');
    }
  } catch (e) {
    print('❌ Simple encryption/decryption error: $e\n');
  }

  // Test 2: Full API payload encryption/decryption
  print('2. Testing full API payload encryption/decryption...');
  final fullPayload = {
    "card_details": {
      "cardNumber": "",
      "expiryMonth": "",
      "expiryYear": "",
      "cvv": "",
      "cardName": ""
    },
    "other_details": {
      "udf1": "",
      "udf2": "",
      "udf3": "",
      "udf4": "",
      "udf5": "",
      "udf6": "",
      "udf7": ""
    },
    "ship_details": {
      "shipAddress": "",
      "shipCity": "",
      "shipState": "",
      "shipCountry": "",
      "shipZip": "",
      "shipDays": "",
      "addressCount": ""
    },
    "txn_details": {
      "agId": "yagout",
      "meId": testMeId,
      "orderNo": "TEST_${DateTime.now().millisecondsSinceEpoch}",
      "amount": "1",
      "country": "ETH",
      "currency": "ETB",
      "transactionType": "SALE",
      "sucessUrl": "https://example.com/success",
      "failureUrl": "https://example.com/failure",
      "channel": "API"
    },
    "item_details": {"itemCount": "", "itemValue": "", "itemCategory": ""},
    "cust_details": {
      "customerName": "",
      "emailId": "",
      "mobileNumber": "965680964",
      "uniqueId": "",
      "isLoggedIn": "Y"
    },
    "pg_details": {
      "pg_Id": "67ee846571e740418d688c3f",
      "paymode": "WA",
      "scheme_Id": "7",
      "wallet_type": "telebirr"
    },
    "bill_details": {
      "billAddress": "",
      "billCity": "",
      "billState": "",
      "billCountry": "",
      "billZip": ""
    }
  };

  final fullPlainText = jsonEncode(fullPayload);
  print('Full payload length: ${fullPlainText.length}');

  try {
    final fullEncrypted = AesUtil.encryptToBase64(fullPlainText, testKey);
    print('Full encrypted length: ${fullEncrypted.length}');

    final fullDecrypted = AesUtil.decryptFromBase64(fullEncrypted, testKey);
    print('Full decrypted length: ${fullDecrypted.length}');

    if (fullDecrypted == fullPlainText) {
      print('✅ Full payload encryption/decryption: SUCCESS\n');
    } else {
      print('❌ Full payload encryption/decryption: FAILED\n');
    }
  } catch (e) {
    print('❌ Full payload encryption/decryption error: $e\n');
  }

  // Test 3: Verify against known working encryption from documentation
  print('3. Testing against known working encryption...');
  const knownEncrypted =
      'lq1FilIDHAD/9Cx4innDJVF+oF2ow673w/wDf969AT48VPCrvfLwX2mdCQLYB77SSq5n5sOqsxT/+fizkAEMyTi8b90BLqKbVIH6aR2uYv1dk9PG0XYXF4LOp6mzuTYinU1AydyCCNSEURPlxn//QC3YAZCt13YGi2a+ZPp8TVLE7YNQxjeqaZV9uIoRLLl7zOXw0G5aU+xalGwSsFZLsE2GKN9hg+zQJ2VOJFZao88TBcrXhQOnMA9r88zNlXuoqBfdQoBwvcU/ERcRevRjcYmz1lum28NRDl0//Xlnx1JBXlh94XcNl6L5U+L7HwsAUEeVM6Fmb5+HvW7W8ZozspukVfeXdxNO2FdvcqccXrrEWpSJHop2RtLwEqOuA3B3e2Fpbb9OBmrcCMvgRR3KgjDTll/LMuOpb/2Ad3VLLfTfwmPoyzwTzFuKpKc3c/+A52LfNgBJ4FlmHQ37b70Nf61ORjDL4g0TdHaNb1hw7IgwOxo1IDOpIr83kdHoeyF3MMGr11AqeEUOBpblU4NvLi6++dEUdetH0Ysglrilis8MRhNJAhVqrlHFnxdAag9CO2nsQRDN2d+CpYD0bEej9oz0c1EOD95RS1DnZyNT1W0pj3CaPDS9ehZlYVmOfzbDKRs7QpDJf+Lf52xU1lByCEXGy958IbsjaCo8aaBytpsVAxC/VmkWJh1TSXeg3bZC3Ck7Lu08U6Rvfinz42qEbPQaID7RyUFQPCDwKvUKjcspbLIruYh9dmO2gPVYU1BSPxjpqaP7BxzjfYf9y0Eb+JMMGEzqg/MaohGeeROruAUea6h6820bAl2/NBZ7s/N8VHdZtepwjV/tUAJTg9BnZWrbzB/VbVb9SHiPNOWHr5SziTJV2RgmP7eXgf5EBPHnG48M2vcUPZ98Uy8Z6BuW8jv+63EunktJE5Lo5A0rPKr4F188thbEJEyBxz1sNyD0se4K1QFLx4A6vmyqukXRrTD7EmKFIqDyp6rKLJI/NxJhPId3VraYYtFodM47DPXbFfeDKBlHMUJRVnDCZQV64QHYMps39QJ23ZF1KIe2aS5Jo3uqjwEc7vNC8JcnleD3QvAZ03p3TedcegBuXqVhfZM35Y5+T3/2L+fd3MsHmjefvGblEHh27aUOHCERULTxOnXZyFMYChZOv7fFjsHY82VwQTrMKvBED+uXjrkLFfx3BXnhzIdc24Pi9Y6rV0Jn+SNtvEz2r7+4co8U8fLgBTDLGVXsZMaFjnbtCiIlu4eSwRHyefyNZwCtMs0cYXmsf+hqMHiyUGMeOVatO7c9dr8n85m2bOugCGMv03KH+DiBnxFO6dK+NHgFBbWZcbFxAVAmQqzAIPlFtvSoK+G343zfHhaHgU8IjKgFaEnGJU1DGhOC4IQJppVCt5t3HBA/UvS/JNPRe0E8R0Qdvnd1rMeABnXwSIsf1ngR3a7gITTvhw17W5riqHXYW/0PXzyqO8yMm8cugMtr35LAX2+vWU7NktqKKpsGPBCLY7fuocJ7FKNesJFUVx9wWFyidJyN1A0WJ/GeG7VU0FwTdHdTf0BykNBfCao7JO9RKIa6jWVDS8Nv75FUPtEztL1OCltUES25ZKlYAfQ64N6w6ug6kPgdQDEHe795fTxPRCVoha270w8D8jXjQksXgPsIWdZUhckZ5GqsIcD73M8jpTdJg/bBKb1IlCfW2TVYYxRhBB011oq/SpXxRtVJlL3LYhpRgLB7wwAFkUN74bJWidc+rspjiKs+CSmiI+RV6PwMh09ljMfdMzEG/lZWgPyyNBlrz7Sf8oOmDyCFpr0CvoW9+YT8jwaK5VzGNs/SNdkClozKaL8jMZPrfLEM8rZsZqR3';

  try {
    final decryptedKnown = AesUtil.decryptFromBase64(knownEncrypted, testKey);
    print('Decrypted known working encryption: $decryptedKnown');
    print('✅ Known encryption decryption: SUCCESS\n');
  } catch (e) {
    print('❌ Known encryption decryption error: $e\n');
  }

  print('=== Encryption Test Complete ===');
}
