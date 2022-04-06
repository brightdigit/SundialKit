enum WCSendMessageResult {
  case applicationContext
  case reply(WCMessage)
  case failure(Error)
  case noCompanion
}
