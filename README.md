ErlangMQ
=
Usage
-
- `./start.sh`
    - Starts the message queue server as a background process

**Exposed admin utilities (over web):**
- Check the list of topics used on the system
    - get query at the following endpoint: `http://localhost:8080/list/queues`
- Check the number of messages relayed over different topics on the system
    - get query at the following endpoint: `http://localhost:8080/list/quantity`

**Utilities at Client:**
- publish some data over a topic
    - `publish topicName Content`
- subscribe to a topic to receive messages
    - `subscribe topicName`
