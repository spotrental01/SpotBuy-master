import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Utils/size_config.dart';
import '../../models/Core_Model/categories_model.dart';
import '../../provider/Vehicle/vehicle_list_provider.dart';
import '../ChatRoom/chat_screen.dart';
import '../vehicle_detail_screen.dart';

class MainVehicleList extends StatelessWidget {
  const MainVehicleList({
    Key? key,
    required this.selectedCategory,
  }) : super(key: key);

  final CategoriesModel selectedCategory;

  void fetchData(List data, BuildContext context) {
    Provider.of<VehicleProvider>(context).fetchAllVehicleData(data);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = size.height * .316;
    final double itemWidth = size.width / 2;
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vehicle_database')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("No item found!!!"),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var data = snapshot.data!.docs as List;

            print("Temprory Data is:- $data");
            // print(data[0]['image']);\
            // data.forEach((element) {});
            fetchData(data, context);

            final vehicleList = Provider.of<VehicleProvider>(context)
                .getVehicleById(selectedCategory.id);
            return GridView.count(
              crossAxisCount: 2,
              childAspectRatio: (itemWidth / itemHeight),
              padding: EdgeInsets.zero,
              /*itemCount: vehicleList.length,
              itemBuilder: (context, index) =>*/
              children: [
                for (var index = 0; index < vehicleList.length; index++)
                  index != null
                      ? SizedBox(
                          // height: 130,
                          child: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VehicleDetailScreen(
                                    docId: snapshot.data!.docs[index].id,
                                    vehicleType: snapshot.data!.docs[index]
                                        .get('vehicleType'),
                                    itemBy: snapshot.data!.docs[index]
                                        .get('itemBy'),
                                  ),
                                )),
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 140,
                                        child: Image.network(snapshot
                                            .data!.docs[index]
                                            .get('image')[0])),
                                    Text(
                                      "${snapshot.data!.docs[index].get('brand')} ${snapshot.data!.docs[index].get('vehicle')}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Rs ${snapshot.data!.docs[index].get('sellAmount')}",
                                      style: TextStyle(
                                        letterSpacing: 1,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index].get('yearModel')} | ${snapshot.data!.docs[index].get('kmDriven')}KM",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
              ],
            );
          }),
    );
  }
}
