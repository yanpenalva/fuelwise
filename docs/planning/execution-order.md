# Execution Order

```text
ENV → V0 → V1 → HOST
```

## Sequence

1. Document the product and scope.
2. Complete and approve ENV.
3. Implement V0.
4. Implement V1.
5. Create the minimum local APK hosting after V1 is functional.
6. Validate installation over the local network and through host ADB.
7. Validate offline operation outside Wi-Fi.

V1 depends on the approved Docker environment. Local APK hosting depends on a functional V1. Offline testing depends on an APK installed on a device.
