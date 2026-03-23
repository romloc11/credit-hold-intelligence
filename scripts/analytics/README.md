# Analytics Layer

This layer contains historical and analytical tables used to support
advanced data modeling patterns such as Slowly Changing Dimensions (SCD).

## Tables

### bridge_cliente_empleado

Tracks historical relationships between customers and employees.

Implements **SCD Type 2** to preserve changes in customer account ownership
and commercial team assignments.

## Load Process

The table is populated by:

analytics.proc_load_bridge_cliente_empleado

which compares the current CRM state against the stored historical records
and inserts new versions when changes are detected.
