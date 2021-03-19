class ServiceOrderSlot {
  String SlotAvailable;
  String TimingSlotName;
  String SlotFromTime;
  String SlotToTime;
  String SlotTimeLabel;
  String SlotNumber;

  ServiceOrderSlot(this.SlotAvailable, this.TimingSlotName, this.SlotFromTime,
      this.SlotToTime, this.SlotTimeLabel, this.SlotNumber);

  ServiceOrderSlot.fromJson(Map<String, dynamic> json) {
    SlotAvailable = json["SlotAvailable"];
    TimingSlotName = json["TimingSlotName"];
    SlotFromTime = json["SlotFromTime"];
    SlotToTime = json["SlotToTime"];
    SlotTimeLabel = json["SlotTimeLabel"];
    SlotNumber = json["SlotNumber"];
  }
}
