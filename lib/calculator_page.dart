import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class UnifiedCalculatorPage extends StatefulWidget {
  const UnifiedCalculatorPage({super.key});

  @override
  _UnifiedCalculatorPageState createState() => _UnifiedCalculatorPageState();
}

class _UnifiedCalculatorPageState extends State<UnifiedCalculatorPage> {
  String selectedCalculator = 'Calculator'; // Default calculator type
  final List<String> calculatorTypes = [
    'Calculator',
    'Weight Converter',
    'Temperature Calculator',
    'Currency Calculator'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Multi Calculator'),
        backgroundColor: const Color(0xFF8D6E63),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Dropdown for calculator selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calculate, color: Color(0xFF8D6E63)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE9E7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF8D6E63)),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCalculator,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8D6E63)),
                    elevation: 16,
                    style: const TextStyle(color: Color(0xFF5D4037), fontSize: 18),
                    underline: Container(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCalculator = value!;
                      });
                    },
                    items: calculatorTypes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Calculator content
          Expanded(
            child: _buildSelectedCalculator(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCalculator() {
    switch (selectedCalculator) {
      case 'Calculator':
        return const CalculatorHome();
      case 'Weight Converter':
        return const WeightConverterPage();
      case 'Temperature Calculator':
        return const TemperatureCalculatorPage();
      case 'Currency Calculator':
        return const CurrencyCalculatorPage();
      default:
        return const Center(child: Text('Select a calculator'));
    }
  }
}

// Include all the existing calculator classes here
// CalculatorHome class
class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String input = '';
  String result = '0';
  final int maxResult = 1000000000;

  void appendInput(String value) {
    setState(() {
      const operators = ['+', '-', 'x', '÷'];

      if (input.isEmpty && value == '-') {
        input += value;
      } else if (input.isNotEmpty) {
        String lastChar = input[input.length - 1];

        if (operators.contains(lastChar) && operators.contains(value)) {
          if (!(lastChar == '-' && value == '-')) {
            input = input.substring(0, input.length - 1) + value;
          }
        } else {
          input += value;
        }
      } else {
        input += value;
      }
    });
  }

  void calculateResult() {
    try {
      if (input.isEmpty) return;

      String evalInput = input.replaceAll('x', '*').replaceAll('÷', '/');

      // Handle square root
      evalInput = evalInput.replaceAllMapped(
          RegExp(r'√(\d+(\.\d+)?)'), (Match m) => 'sqrt(${m.group(1)})');

      // Handle trigonometric functions
      evalInput = evalInput.replaceAllMapped(
        RegExp(r'(sin|cos|tan)\(([^)]+)\)'),
            (match) {
          String function = match.group(1)!;
          String angle = match.group(2)!;
          // Convert degrees to radians for trig functions
          double radians = double.parse(angle) * (3.141592653589793 / 180);
          return '$function($radians)';
        },
      );

      // Parse and evaluate the expression
      Parser parser = Parser();
      Expression exp = parser.parse(evalInput);
      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      if (evalResult.abs() > maxResult) {
        result = 'Maksimal: $maxResult';
      } else {
        result = evalResult.toStringAsFixed(2);
        if (result.endsWith('.00')) {
          result = result.substring(0, result.length - 3);
        }
      }
    } catch (e) {
      result = 'Error';
    }
    setState(() {});
  }

  void clearInput() {
    setState(() {
      input = '';
      result = '0';
    });
  }

  void deleteLast() {
    if (input.isNotEmpty) {
      setState(() {
        input = input.substring(0, input.length - 1);
      });
    }
  }

  void addTrigFunction(String func) {
    setState(() {
      input += '$func(';
    });
  }

  void _hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _hideKeyboard(context),
      child: buildCalculatorTab(),
    );
  }

  Widget buildCalculatorTab() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Input Display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBE9E7), Color(0xFFD7CCC8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  input,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        // Buttons
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                ...buildButtons([
                  'sin', 'cos', 'tan', '√',
                  '(', ')', 'C', '⌫',
                  '7', '8', '9', '÷',
                  '4', '5', '6', 'x',
                  '1', '2', '3', '-',
                  '0', '.', '=', '+',
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildButtons(List<String> buttons) {
    return buttons.map((btn) {
      return ElevatedButton(
        onPressed: () {
          if (btn == '=') {
            calculateResult();
          } else if (btn == 'C') {
            clearInput();
          } else if (btn == '⌫') {
            deleteLast();
          } else if (btn == 'sin' || btn == 'cos' || btn == 'tan') {
            addTrigFunction(btn);
          } else {
            appendInput(btn);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF5D4037),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          btn,
          style: const TextStyle(fontSize: 18, color: Color(0xFF5D4037)),
        ),
      );
    }).toList();
  }
}

// WeightConverterPage class
class WeightConverterPage extends StatefulWidget {
  const WeightConverterPage({super.key});

  @override
  _WeightConverterPageState createState() => _WeightConverterPageState();
}

class _WeightConverterPageState extends State<WeightConverterPage> {
  final TextEditingController _weightController = TextEditingController();
  double? result;
  String fromUnit = 'Kilogram'; // Default satuan asal
  String toUnit = 'Pound'; // Default satuan tujuan

  // Semua satuan berat internasional dan Amerika
  final List<String> weightUnits = [
    // Satuan Internasional
    'Kilogram',
    'Hektogram',
    'Dekagram',
    'Gram',
    'Desigram',
    'Centigram',
    'Milligram',
    // Satuan Amerika
    'Ounce',
    'Pound',
    'Stone',
    'Short Ton',
    'Long Ton',
  ];

  // Fungsi untuk menghitung konversi berat
  void calculateConversion() {
    if (_weightController.text.isEmpty) {
      showErrorDialog('Silakan masukkan berat yang ingin dikonversi.');
      return;
    }

    double inputWeight = double.tryParse(_weightController.text) ?? -1;
    if (inputWeight == -1) {
      showErrorDialog('Masukkan berat yang valid.');
      return;
    }

    setState(() {
      // Konversi berat berdasarkan satuan
      result = convertWeight(inputWeight, fromUnit, toUnit);
    });
  }

  // Fungsi utama untuk melakukan konversi
  double convertWeight(double value, String from, String to) {
    // Konversi nilai dari satuan asal ke Kilogram (sebagai basis)
    double valueInKilogram = value * _getConversionFactor(from);

    // Konversi nilai dari Kilogram ke satuan tujuan
    return valueInKilogram / _getConversionFactor(to);
  }

  // Faktor konversi ke dan dari Kilogram
  double _getConversionFactor(String unit) {
    switch (unit) {
    // Satuan Internasional
      case 'Kilogram':
        return 1; // 1 kg = 1 kg
      case 'Hektogram':
        return 0.1; // 1 hg = 0.1 kg
      case 'Dekagram':
        return 0.01; // 1 dag = 0.01 kg
      case 'Gram':
        return 0.001; // 1 g = 0.001 kg
      case 'Desigram':
        return 0.0001; // 1 dg = 0.0001 kg
      case 'Centigram':
        return 0.00001; // 1 cg = 0.00001 kg
      case 'Milligram':
        return 0.000001; // 1 mg = 0.000001 kg

    // Satuan Amerika
      case 'Ounce':
        return 0.0283495; // 1 oz = 0.0283495 kg
      case 'Pound':
        return 0.453592; // 1 lb = 0.453592 kg
      case 'Stone':
        return 6.35029; // 1 stone = 6.35029 kg
      case 'Short Ton':
        return 907.1847; // 1 short ton = 907.1847 kg
      case 'Long Ton':
        return 1016.0469; // 1 long ton = 1016.0469 kg

      default:
        return 1; // Default ke Kilogram
    }
  }

  // Menampilkan dialog error jika input tidak valid
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input berat
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Masukkan berat ($fromUnit)',
                labelStyle: const TextStyle(fontSize: 18),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Dropdown untuk memilih satuan berat asal dan tujuan
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDropdownButton(
                  'from',
                  backgroundColor: const Color(0xFF8D6E63), // Warna latar belakang HEX untuk dropdown 'from'
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 32, color: Color(0xFF8D6E63)),
                  onPressed: () {
                    setState(() {
                      // Tukar satuan berat asal dan tujuan
                      String temp = fromUnit;
                      fromUnit = toUnit;
                      toUnit = temp;
                    });
                  },
                ),
                _buildDropdownButton(
                  'to',
                  backgroundColor: const Color(0xFF8D6E63), // Warna latar belakang HEX untuk dropdown 'to'
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol untuk melakukan konversi
            ElevatedButton(
              onPressed: calculateConversion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                backgroundColor: const Color(0xFF8D6E63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Konversi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Hasil konversi
            if (result != null)
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(top: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Hasil: ${result!.toStringAsFixed(5)} $toUnit',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton(String unitType, {required Color backgroundColor}) {
    String selectedUnit = unitType == 'from' ? fromUnit : toUnit; // Tentukan satuan yang digunakan
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedUnit,
        isExpanded: true,
        dropdownColor: backgroundColor,
        underline: Container(),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        items: weightUnits.map((unit) {
          return DropdownMenuItem<String>(
            value: unit,
            child: Text(unit, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            if (unitType == 'from') {
              fromUnit = value!;
            } else {
              toUnit = value!;
            }
          });
        },
      ),
    );
  }
}

// TemperatureCalculatorPage class
class TemperatureCalculatorPage extends StatefulWidget {
  const TemperatureCalculatorPage({super.key});

  @override
  _TemperatureCalculatorPageState createState() => _TemperatureCalculatorPageState();
}

class _TemperatureCalculatorPageState extends State<TemperatureCalculatorPage> {
  final TextEditingController _temperatureController = TextEditingController();
  double? result;
  String fromScale = 'Celsius'; // Default skala asal
  String toScale = 'Fahrenheit'; // Default skala tujuan

  // Fungsi untuk menghitung konversi suhu
  void calculateConversion() {
    if (_temperatureController.text.isEmpty) {
      showErrorDialog('Silakan masukkan suhu yang ingin dikonversi.');
      return;
    }

    double inputTemperature = double.tryParse(_temperatureController.text) ?? -1;
    if (inputTemperature == -1) {
      showErrorDialog('Masukkan suhu yang valid.');
      return;
    }

    setState(() {
      // Konversi suhu berdasarkan skala
      if (fromScale == 'Celsius') {
        if (toScale == 'Fahrenheit') {
          result = (inputTemperature * 9 / 5) + 32;
        } else if (toScale == 'Kelvin') {
          result = inputTemperature + 273.15;
        } else if (toScale == 'Reamur') {
          result = inputTemperature * 4 / 5;
        }
      } else if (fromScale == 'Fahrenheit') {
        if (toScale == 'Celsius') {
          result = (inputTemperature - 32) * 5 / 9;
        } else if (toScale == 'Kelvin') {
          result = (inputTemperature - 32) * 5 / 9 + 273.15;
        } else if (toScale == 'Reamur') {
          result = (inputTemperature - 32) * 4 / 9;
        }
      } else if (fromScale == 'Kelvin') {
        if (toScale == 'Celsius') {
          result = inputTemperature - 273.15;
        } else if (toScale == 'Fahrenheit') {
          result = (inputTemperature - 273.15) * 9 / 5 + 32;
        } else if (toScale == 'Reamur') {
          result = (inputTemperature - 273.15) * 4 / 5;
        }
      } else if (fromScale == 'Reamur') {
        if (toScale == 'Celsius') {
          result = inputTemperature * 5 / 4;
        } else if (toScale == 'Fahrenheit') {
          result = (inputTemperature * 9 / 4) + 32;
        } else if (toScale == 'Kelvin') {
          result = (inputTemperature * 5 / 4) + 273.15;
        }
      }
    });
  }

  // Menampilkan dialog error jika input tidak valid
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input suhu
            TextField(
              controller: _temperatureController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Masukkan suhu ($fromScale)',
                labelStyle: const TextStyle(fontSize: 18),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Dropdown untuk memilih skala suhu asal dan tujuan
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDropdownButton(
                  'from',
                  backgroundColor: const Color(0xFF8D6E63), // Warna latar belakang HEX untuk dropdown 'from'
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 32, color: Color(0xFF8D6E63)),
                  onPressed: () {
                    setState(() {
                      // Tukar skala suhu asal dan tujuan
                      String temp = fromScale;
                      fromScale = toScale;
                      toScale = temp;
                    });
                  },
                ),
                _buildDropdownButton(
                  'to',
                  backgroundColor: const Color(0xFF8D6E63), // Warna latar belakang HEX untuk dropdown 'to'
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol untuk melakukan konversi
            ElevatedButton(
              onPressed: calculateConversion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Menambah ukuran tombol
                backgroundColor: const Color(0xFF8D6E63), // Warna latar belakang tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Membuat sudut tombol melengkung
                ),
              ),
              child: const Text(
                'Konversi',
                style: TextStyle(
                  fontSize: 18, // Ukuran teks tombol
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Warna teks tombol
                ),
              ),
            ),

            // Hasil konversi
            if (result != null)
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(top: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Hasil: ${result!.toStringAsFixed(2)} $toScale',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildDropdownButton(String scaleType, {required Color backgroundColor}) {
    String selectedScale = scaleType == 'from' ? fromScale : toScale; // Tentukan skala yang digunakan
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor, // Warna latar belakang berdasarkan input HEX
        border: Border.all(color: Colors.grey.shade400), // Border dropdown
        borderRadius: BorderRadius.circular(8), // Sudut melengkung container
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedScale,
        isExpanded: true,
        dropdownColor: backgroundColor, // Warna dropdown saat dibuka
        underline: Container(), // Menghapus garis bawah dropdown bawaan
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black, // Warna teks dropdown
        ),
        items: ['Celsius', 'Fahrenheit', 'Kelvin', 'Reamur'].map((scale) {
          return DropdownMenuItem<String>(
            value: scale,
            child: Text(scale),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            if (scaleType == 'from') {
              fromScale = value!;
            } else {
              toScale = value!;
            }
          });
        },
      ),
    );
  }
}



// CurrencyCalculatorPage class
class CurrencyCalculatorPage extends StatefulWidget {
  const CurrencyCalculatorPage({super.key});

  @override
  _CurrencyCalculatorPageState createState() => _CurrencyCalculatorPageState();
}

class _CurrencyCalculatorPageState extends State<CurrencyCalculatorPage> {
  final TextEditingController _amountController = TextEditingController();
  double? result;
  String fromCurrency = 'IDR'; // Default source currency
  String toCurrency = 'USD'; // Default target currency

  final Map<String, double> baseExchangeRates = {
    'IDR': 14920.0,
    'USD': 1.0,
    'EUR': 0.85,
    'JPY': 110.0,
    'SAR': 3.75,
    'GBP': 0.74,
    'AUD': 1.34,
    'CAD': 1.25,
    'INR': 73.5,
    'CNY': 6.45,
  };

  void calculateConversion() {
    if (_amountController.text.isEmpty) {
      showErrorDialog('Please enter an amount to convert.');
      return;
    }

    double inputAmount = double.tryParse(_amountController.text) ?? -1;
    if (inputAmount <= 0) {
      showErrorDialog('Enter a valid amount greater than 0.');
      return;
    }

    setState(() {
      double fromRate = baseExchangeRates[fromCurrency] ?? 1.0;
      double toRate = baseExchangeRates[toCurrency] ?? 1.0;
      result = (inputAmount / fromRate) * toRate;
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input amount
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter amount ($fromCurrency)',
                  labelStyle: const TextStyle(color: Color(0xFF5D4037)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown for selecting currencies
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCurrencyDropdown(fromCurrency, (value) {
                  setState(() {
                    fromCurrency = value!;
                  });
                }),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 32, color: Color(0xFF8D6E63)),
                  onPressed: () {
                    setState(() {
                      String temp = fromCurrency;
                      fromCurrency = toCurrency;
                      toCurrency = temp;
                    });
                  },
                ),
                _buildCurrencyDropdown(toCurrency, (value) {
                  setState(() {
                    toCurrency = value!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 20),

            // Convert button
            ElevatedButton(
              onPressed: calculateConversion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF8D6E63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Convert', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Conversion result
            if (result != null)
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD7CCC8), Color(0xFFFBE9E7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 20),
                child: Text(
                  'Result: ${result!.toStringAsFixed(2)} $toCurrency',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(String selectedCurrency, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<String>(
        value: selectedCurrency,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
        items: baseExchangeRates.keys.map((currency) {
          return DropdownMenuItem<String>(
            value: currency,
            child: Text(
              currency,
              style: const TextStyle(color: Color(0xFF5D4037), fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
