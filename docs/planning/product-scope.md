# Product Scope

Fuelwise is an offline Flutter Android application that compares ethanol and gasoline using prices and vehicle consumption entered by the user.

## Functional objective

- Calculate the recommendation between gasoline and ethanol.
- Explain the rule used for the decision.
- Show cost per kilometer, maximum recommended ethanol price, and the difference between ratio and threshold.
- Work without a backend or network connection after installation.

## Approved formulas

- Ratio = ethanol price / gasoline price.
- Standard threshold = `0.70`.
- Custom threshold = ethanol consumption / gasoline consumption.
- Recommend ethanol when ratio is less than or equal to the active threshold.
- Cost per kilometer = price / consumption.
- Maximum ethanol price = gasoline price * active threshold.
- Difference = ratio - active threshold.

## Scope constraints

- One vehicle only.
- No real refueling records.
- CSV export is limited to one history entry or one calendar month.
- No maps or geolocation.
- No backend or synchronization.
- No Flutter Web.
- No app-store publishing in this delivery.
