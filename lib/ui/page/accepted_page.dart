import 'package:flutter/material.dart';
import 'package:foodcafe/controller/controller.dart';
import 'package:foodcafe/resource/colors.dart';
import 'package:foodcafe/resource/value.dart';
import 'package:foodcafe/ui/widget/delivery_person_information.dart';
import 'package:foodcafe/ui/widget/extra_order_detail.dart';
import 'package:foodcafe/ui/widget/order_address.dart';
import 'package:foodcafe/ui/widget/order_detail.dart';
import 'package:foodcafe/ui/widget/order_status.dart';
import 'package:foodcafe/utils/state_status.dart';
import 'package:get/get.dart';
import 'package:foodcafe/utils/extensions.dart';

class AcceptedPage extends StatelessWidget {
  final _infoKey = <GlobalKey>[];
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder(
            initState: (_) {
              HomeController.to.searchController.clear();
              HomeController.to.acceptedController.search.value = '';
              AcceptedController.to.fetchAccepted();
            },
            init: AcceptedController(),
            builder: (_) => Obx(() => RefreshIndicator(
                key: _refreshKey,
                backgroundColor: refreshBackgroundColor,
                color: refreshColor,
                onRefresh: () async {
                  if (AcceptedController.to.refreshStatus.value ==
                      RefreshStatus.SUCCESS) {
                    _refreshKey.currentState.dispose();
                  }

                  if (AcceptedController.to.refreshStatus.value ==
                      RefreshStatus.INITIAL) {
                    _refreshKey.currentState.show();
                    AcceptedController.to.fetchAccepted(isRefresh: true);
                  }
                },
                child: listView(
                    stateStatus:  AcceptedController.to.stateStatus.value,
                    dataNotFoundMessage: dataNotAcceptedMessage,
                    length:  AcceptedController.to.rxAcceptedList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var _accepted =  AcceptedController.to.rxAcceptedList[index];
                      _infoKey.add(GlobalKey(debugLabel: '$index'));

                      return Obx(() => Visibility(
                          visible:  AcceptedController.to
                              .findUniqueId(_accepted.uniqueId),
                          child: Card(
                              elevation: cardViewElevation,
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        OrderDetail(
                                            infoKey: _infoKey[index],
                                            orderMainList: _accepted,
                                            orderList: _accepted.orderList,
                                            otherChargeList:
                                                _accepted.otherChargeList),
                                        _accepted.extraOrderList.isEmpty
                                            ? Container()
                                            : ExtraOrderDetail(
                                                extraTotalAmount: _accepted
                                                    .extraOrderTotalAmount,
                                                extraOrderList:
                                                    _accepted.extraOrderList),
                                        Obx(() => Visibility(
                                            visible: _accepted
                                                .deliveryPersonDetail
                                                .isSelect
                                                .value,
                                            child: DeliveryPersonInformation(
                                                deliveryPersonDetail: _accepted
                                                    .deliveryPersonDetail))),
                                        OrderAddress(
                                            orderPersonDetail:
                                                _accepted.orderPersonDetail),
                                        SizedBox(height: 10),
                                        OrderStatus(
                                            uniqueId: _accepted.uniqueId,
                                            orderStatus: foodReadyButton,
                                            rejectCallBack: () =>
                                                AcceptedController.to.removeOrder(
                                                    uniqueId:
                                                        _accepted.uniqueId,
                                                    message:
                                                        acceptedOrderRejectMessage,
                                                    isShowToast: true),
                                            orderCallBack: () =>
                                                AcceptedController.to.removeOrder(
                                                    uniqueId:
                                                        _accepted.uniqueId,
                                                    message:
                                                        acceptedOrderReadyMessage,
                                                    isShowToast: true))
                                      ])))));
                    })))));
  }
}
