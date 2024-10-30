import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Prototype',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 223, 64, 88)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var items = 0;
  List<Product> cart = [];

  void addItem(Product product) {
    product.quantity++;
    notifyListeners();
  }

    void removeItem(Product product) {
    if (product.quantity > 1) {
      product.quantity--;
    }
    notifyListeners();
  }

  void toggleCart(Product product) {
    if (cart.contains(product)) {
      cart.remove(product);
      product.quantity = 0;
    } else {
      cart.add(product);
      addItem(product);
    }
    printCartItems();
    notifyListeners();
  }

  void clearCart() {
    cart.forEach((product) => product.quantity = 0);
    cart.clear();
    notifyListeners();
  }


  void printCartItems() { //log de itens do carrinho no console
      String cartContents = cart.map((item) => item.name).join(', ');
      print('Cart Items: $cartContents');
    }
}

  List<Product> products = [
    Product(name: 'Queijo Colonial', price: 40.99),
    Product(name: 'Salame', price: 25.50),
    Product(name: 'Doce de leite', price: 15.75),
    Product(name: 'Geleia de frutas', price: 30.00),
    Product(name: 'Pão caseiro', price: 50.00),
  ];

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MenuPage();
        break;
      case 1:
        page = CartPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout),
            label: 'Carrinho',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }
}

class MenuPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    

    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Produto01(product: products[index]);
              }
            ),
          ),
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: Colors.black,
    );

    var appState = context.watch<MyAppState>();

    if (appState.cart.isEmpty) {
      return Center(
        child: Text('Carrinho vazio.'),
      );
    }

    double totalPrice = appState.cart.fold(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Carrinho'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Seu carrinho tem ${appState.cart.length} itens:',
              style: style.copyWith(fontSize: 20),
            ),
          ),
          CartContent(appState: appState, style: style),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: R\$ ${totalPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  helpText: 'Escolha a data de entrega',
                ).then((selectedDate) {
                  if (selectedDate != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String? selectedTimeSlot;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text('Escolha o horário de entrega'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      'Data escolhida: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                                  SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    children: [
                                      for (var timeSlot in ['10h-12h', '14h-16h', '18h-20h'])
                                        ChoiceChip(
                                          label: Text(timeSlot),
                                          selected: selectedTimeSlot == timeSlot,
                                          onSelected: (selected) {
                                            setState(() {
                                              selectedTimeSlot = selected ? timeSlot : null;
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: selectedTimeSlot == null ? null : () {
                                    Navigator.of(context).pop();
                                    
                                    // Show payment type dialog after choosing delivery time
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        String? selectedPaymentType;

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title: Text('Escolha o método de pagamento'),
                                              content: Wrap(
                                                spacing: 10,
                                                children: [
                                                  for (var paymentType in ['Pix', 'Dinheiro (apenas retirada)'])
                                                    ChoiceChip(
                                                      label: Text(paymentType),
                                                      selected: selectedPaymentType == paymentType,
                                                      onSelected: (selected) {
                                                        setState(() {
                                                          selectedPaymentType = selected ? paymentType : null;
                                                        });
                                                      },
                                                    ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: selectedPaymentType == null ? null : () {
                                                    Navigator.of(context).pop();

                                                    // Show final confirmation with delivery date, time, and payment type
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text('Resumo da Compra'),
                                                          content: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                'Data de Entrega: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}, ${selectedTimeSlot}',
                                                                style: theme.textTheme.bodyMedium,
                                                              ),
                                                              Text(
                                                                'Tipo de Pagamento: $selectedPaymentType',
                                                                style: theme.textTheme.bodyMedium,
                                                              ),
                                                              Text(
                                                                'Total da Compra: R\$ ${totalPrice.toStringAsFixed(2)}',
                                                                style: theme.textTheme.bodyMedium,
                                                              ),
                                                              SizedBox(height: 10),
                                                              FlutterLogo(size: 80),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                appState.clearCart();
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Text('Fechar'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text('Confirmar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Text('Confirmar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  }
                });
              },
              child: Text('Finalizar Compra'),
            ),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}

class CartContent extends StatelessWidget {
  const CartContent({
    super.key,
    required this.appState,
    required this.style,
  });

  final MyAppState appState;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: appState.cart.length,
        itemBuilder: (context, index) {
          var product = appState.cart[index];
          return ListTile(
            leading: FlutterLogo(size: 80),
            title: Text(product.name),
            subtitle: Text('R\$ ${(product.price * product.quantity).toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (product.quantity > 1) {
                      appState.removeItem(product);
                    }
                  },
                ),
                Text(product.quantity.toString(), style: style.copyWith(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    appState.addItem(product);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    appState.toggleCart(product);
                  },
                  child: Icon(Icons.remove_shopping_cart),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Produto01 extends StatefulWidget {
  final Product product;

  const Produto01({Key? key, required this.product}) : super(key: key);

  @override
  State<Produto01> createState() => _Produto01State();
}

class _Produto01State extends State<Produto01> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: Colors.black,
    );

    IconData icon;
    if (appState.cart.contains(widget.product)) {
      icon = Icons.shopping_cart;
    } else {
      icon = Icons.shopping_cart_outlined;
    }

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            FlutterLogo(size: 80),
            SizedBox(height: 10),
            Text(widget.product.name, style: style.copyWith(fontSize: 25,)),
            SizedBox(height: 10),
            SizedBox(
              child: Row(
                children: [
                  Text('R\$ ', style: style.copyWith(fontSize: 25)),
                  Text((widget.product.price).toStringAsFixed(2), style: style.copyWith(fontSize: 25)),
                  Spacer(),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        appState.toggleCart(widget.product);
                      },
                      child: Icon(icon, size: 30),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Product {
  String name;
  double price;
  int quantity;

  Product({required this.name, required this.price, this.quantity = 0});
}