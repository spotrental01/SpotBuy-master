import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotbuy/screens/Sell/seller_profile_header.dart';
import '../vehicle_detail_screen.dart';

class SellerProfile extends StatefulWidget {
  String itemBy;

  SellerProfile({Key? key, required this.itemBy}) : super(key: key);

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  List<dynamic> docIDs = [];
  bool isGoogleAd = false;
  void getDocId() async {
    await FirebaseFirestore.instance
        .collection('vehicle_database')
        .where('itemBy', isEqualTo: widget.itemBy)
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
              print(document.reference);
              docIDs.add(document.reference.id);
              setState(() {});
            },
          ),
        );
  }

  dynamic userDocID = '';

  getUserDocId()  {
    FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: widget.itemBy)
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
          print(document.reference);
          userDocID = document.reference.id;
          setState(() {});
        },
      ),
    );
    return userDocID;
  }

  @override
  void initState()  {
    super.initState();
    getDocId();
    userDocID =  getUserDocId();
    getUserDocId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E3C5D),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios,color: Colors.white,),
        ),
        title: const Text("Profile",style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SellerProfileHeader(itemBy: widget.itemBy,userDocID: userDocID,),
           isGoogleAd ? Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                ),
                width: 200,
                height: 120,
                child: const Center(
                  child: Text(
                    "Google Ads.",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ):SizedBox(),
            Expanded(
              child: ListView.builder(
                itemCount: docIDs.length,
                itemBuilder: (_, index) {
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('vehicle_database')
                        .doc(docIDs[index])
                        .snapshots(),
                    builder: (_, snapshot) {
                      print("Snapshot Data:- $snapshot");
                      if (snapshot.hasError)
                        return Text('Error = ${snapshot.error}');

                      if (snapshot.hasData) {
                        var output = snapshot.data!;
                        List<dynamic> image = [];
                        image = output.get('image');
                        return InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VehicleDetailScreen(
                                  docId: snapshot.data!.id, vehicleType: snapshot.data!.get('vehicleType'), itemBy: snapshot.data!.get('itemBy'),
                                ),
                              )),
                          child: CustomCard(
                            output.get('sellAmount'),
                            output.get('title'),
                            output.get('yearModel'),
                            output.get('kmDriven'),
                            output.get('place'),
                            image[0],
                          ),
                        );
                        // return ListTile(
                        //   title: Text(
                        //     output.get('title'),
                        //   ),
                        // );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget CustomCard(price, name, year, range, address, imageURL) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        elevation: 10,
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 130,
              child: Image.network(
                imageURL,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "₹$price",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
                Text(
                  "$year - ${range}KM",
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined),
                    Text(address),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}
