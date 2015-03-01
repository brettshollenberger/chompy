function socketToObservable(socket) {
  return Rx.Observable.create(function(observer) {
    observer.subscribed = true;

    if (socket.subscribers === undefined) {
      socket.subscribers = [];
    }

    socket.subscribers.push(observer);

    socket.onmessage = function(message) {
      for (index in socket.subscribers) {
        var subscriber = socket.subscribers[index];

        if (subscriber.subscribed) {
          subscriber.onNext(message.data);
        }
      }
    }

    return function() {
      observer.subscribed = false;
    }
  });
}

function toSocketRequest(method, url, body) {
  return JSON.stringify({
    headers: {
      method: method,
      url   : url
    },
    body: body
  });
}
