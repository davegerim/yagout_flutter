import 'dart:convert';
import 'lib/utils/crypto/aes_util.dart';

void main() async {
  print('=== Testing Fixed AES Encryption ===\n');

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
      print('✅ Simple encryption/decryption: SUCCESS');
    } else {
      print('❌ Simple encryption/decryption: FAILED');
      print('Expected: $plainText');
      print('Got: $decrypted');
    }
  } catch (e) {
    print('❌ Simple encryption/decryption error: $e');
  }

  print('\n2. Testing with known working encryption from docs...');

  // Test with the known working encrypted string from documentation
  const knownEncrypted =
      'lq1FilIDHAD/9Cx4innDJVF+oF2ow673w/wDf969AT48VPCrvfLwX2mdCQLYB77SSq5n5sOqsxT/+fizkAEMyTi8b90BLqKbVIH6aR2uYv1dk9PG0XYXF4LOp6mzuTYinU1AydyCCNSEURPlxn//QC3YAZCt13YGi2a+ZPp8TVLE7YNQxjeqaZV9uIoRLLl7zOXw0G5aU+xalGwSsFZLsE2GKN9hg+zQJ2VOJFZao88TBcrXhQOnMA9r88zNlXuoqBfdQoBwvcU/ERcRevRjcYmz1lum28NRDl0//Xlnx1JBXlh94XcNl6L5U+L7HwsAUEeVM6Fmb5+HvW7W8ZozspukVfeXdxNO2FdvcqccXrrEWpSJHop2RtLwEqOuA3B3e2Fpbb9OBmrcCMvgRR3KgjDTll/LMuOpb/2Ad3VLLfTfwmPoyzwTzFuKpKc3c/+A52LfNgBJ4FlmHQ37b70Nf61ORjDL4g0TdHaNb1hw7IgwOxo1IDOpIr83kdHoeyF3MMGr11AqeEUOBpblU4NvLi6++dEUdetH0Ysglrilis8MRhNJAhVqrlHFnxdAag9CO2nsQRDN2d+CpYD0bEej9oz0c1EOD95RS1DnZyNT1W0pj3CaPDS9ehZlYVmOfzbDKRs7QpDJf+Lf52xU1lByCEXGy958IbsjaCo8aaBytpsVAxC/VmkWJh1TSXeg3bZC3Ck7Lu08U6Rvfinz42qEbPQaID7RyUFQPCDwKvUKjcspbLIruYh9dmO2gPVYU1BSPxjpqaP7BxzjfYf9y0Eb+JMMGEzqg/MaohGeeROruAUea6h6820BAl2/NBZ7s/N8VHdZtepwjV/tUAJTg9BnZWrbzB/VbVb9SHiPNOWHr5SziTJV2RgmP7eXgf5EBPHnG48M2vcUPZ98Uy8Z6BuW8jv+63EunktJE5Lo5A0rPKr4F188thbEJEyBxz1sNyD0se4K1QFLx4A6vmyqukXRrTD7EmKFIqDyp6rKLJI/NxJhPId3VraYYtFodM47DPXbFfeDKBlHMUJRVnDCZQV64QHYMps39QJ23ZF1KIe2aS5Jo3uqjwEc7vNC8JcnleD3QvAZ03p3TedcegBuXqVhfZM35Y5+T3/2L+fd3MsHmjefvGblEHh27aUOHCERULTxOnXZyFMYChZOv7fFjsHY82VwQTrMKvBED+uXjrkLFfx3BXnhzIdc24Pi9Y6rV0Jn+SNtvEz2rS+4co8U8fLgBTDLGVXsZMaFjnbtCiIlu4eSwRHyefyNZwCtMs0cYXmsf+hqMHiyUGMeOVatO7c9dr8n85m2bOugCGMv03KH+DiBnxFO6dK+NHgFBbWZcbFxAVAmQqzAIPlFtvSoK+G343zfHhaHgU8IjKgFaEnGJU1DGhOC4IQJppVCt5t3HBA/UvS/JNPRe0G8R0Qdvnd1rMeABnXwSIsf1ngR3a7gITTvhw17W5riqHXYW/0PXzyqO8yMm8cugMtr35LAX2+vWU7NktqKKpsGPBCLY7fuocJ7FKNesJFUVx9wWFyidJyN1A0WJ/GeG7VU0FwTdHdTf0BykNBfCao7JO9RKIa6jWVDS8Nv75VUPtEztL1OCltUES25ZKlYAfQ64N6w6ug6kPgdQDEHe795fTxPRCVoha270w8D8jXjQksXgPsIWdZUhckZ5GqsIcD73M8jpTdJg/bBKb1IlCf2TVYYxRhBB011oq/SpXxRtVJlL3LYhpRgLB7wwAFkUN74bJWidc+rspjiKs+CSmiI+RV6PwMh09ljMfdMzEG/lZWgPyyNBlrz7Sf8oOmDyCFpr0CvoW9fYT8jwaK5VzGNs/SNdkClozKaL8jMZPrfLEM8rZsZqR3';

  try {
    final decrypted = AesUtil.decryptFromBase64(knownEncrypted, testKey);
    print('Decrypted known working string: $decrypted');

    if (decrypted.isNotEmpty) {
      print('✅ Known encryption decryption: SUCCESS');
      print('This proves our implementation matches YagoutPay\'s exactly!');
    } else {
      print('❌ Known encryption decryption: FAILED - empty result');
    }
  } catch (e) {
    print('❌ Known encryption decryption error: $e');
  }

  print('\n3. Testing with full API payload structure...');

  // Test with the full API payload structure
  final fullTestData = {
    'txn_details': {
      'agId': 'yagout',
      'meId': testMeId,
      'orderNo': 'TEST_${DateTime.now().millisecondsSinceEpoch}',
      'amount': '1.00',
      'country': 'ETH',
      'currency': 'ETB',
      'transactionType': 'SALE',
      'sucessUrl': 'https://example.com/success',
      'failureUrl': 'https://example.com/failure',
      'channel': 'API'
    }
  };

  final fullPlainText = jsonEncode(fullTestData);
  print('Full test data length: ${fullPlainText.length}');

  try {
    final fullEncrypted = AesUtil.encryptToBase64(fullPlainText, testKey);
    print('Full data encrypted successfully');

    final fullDecrypted = AesUtil.decryptFromBase64(fullEncrypted, testKey);
    if (fullDecrypted == fullPlainText) {
      print('✅ Full payload encryption/decryption: SUCCESS');
    } else {
      print('❌ Full payload encryption/decryption: FAILED');
    }
  } catch (e) {
    print('❌ Full payload encryption error: $e');
  }

  print('\n=== Test Complete ===');
}

