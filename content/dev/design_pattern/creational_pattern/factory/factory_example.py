from abc import ABC, abstractmethod


# ── Product interface ──────────────────────────────────────────────────────────

class Notification(ABC):
    @abstractmethod
    def send(self, message: str) -> str:
        pass


# ── Concrete Products ──────────────────────────────────────────────────────────

class EmailNotification(Notification):
    def __init__(self, address: str):
        self.address = address

    def send(self, message: str) -> str:
        return f"[EMAIL → {self.address}] {message}"


class SMSNotification(Notification):
    def __init__(self, phone: str):
        self.phone = phone

    def send(self, message: str) -> str:
        return f"[SMS → {self.phone}] {message}"


class PushNotification(Notification):
    def __init__(self, device_token: str):
        self.device_token = device_token

    def send(self, message: str) -> str:
        return f"[PUSH → {self.device_token[:8]}...] {message}"


# ── Creator (abstract) ─────────────────────────────────────────────────────────

class NotificationService(ABC):
    """
    The Creator declares the factory method, which must return a Notification.
    Subclasses override it to produce specific types.
    """

    @abstractmethod
    def create_notification(self, recipient: str) -> Notification:
        """Factory Method — subclasses decide what to build."""
        pass

    def notify(self, recipient: str, message: str) -> str:
        """
        Core business logic that USES the product without knowing its type.
        This is the key benefit: this method never changes.
        """
        notification = self.create_notification(recipient)
        return notification.send(message)


# ── Concrete Creators ──────────────────────────────────────────────────────────

class EmailService(NotificationService):
    def create_notification(self, recipient: str) -> Notification:
        return EmailNotification(address=recipient)


class SMSService(NotificationService):
    def create_notification(self, recipient: str) -> Notification:
        return SMSNotification(phone=recipient)


class PushService(NotificationService):
    def create_notification(self, recipient: str) -> Notification:
        return PushNotification(device_token=recipient)


# ── Optional: a simple registry-based factory ──────────────────────────────────

_SERVICES: dict[str, type[NotificationService]] = {
    "email": EmailService,
    "sms":   SMSService,
    "push":  PushService,
}

def get_service(channel: str) -> NotificationService:
    """Convenience function: pick a service by name at runtime."""
    try:
        return _SERVICES[channel.lower()]()
    except KeyError:
        raise ValueError(f"Unknown channel '{channel}'. Choose from: {list(_SERVICES)}")


# ── Demo ───────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    alerts = [
        ("email", "alice@example.com"),
        ("sms",   "+33612345678"),
        ("push",  "abc123def456ghi789"),
    ]

    message = "Your order #4271 has shipped!"

    print("=== Factory Method — Notification Demo ===\n")
    for channel, recipient in alerts:
        service = get_service(channel)
        result  = service.notify(recipient, message)
        print(result)