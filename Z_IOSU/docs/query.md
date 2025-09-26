# Formato de Query para Sparrow - Guía Práctica

## 🎯 Formato Correcto de Query

### ✅ Query para Facturas Detalladas (FUNCIONANDO)

```json
{
  "InvoiceDetails": {
    "InvoiceNumber": "str",
    "InvoiceDate": "str", 
    "PaymentMethod": "str"
  },
  "SupplierDetails": {
    "Name": "str",
    "VAT": "str",
    "Address": "str",
    "Contact": "str"
  },
  "CustomerDetails": {
    "Name": "str",
    "VAT": "str", 
    "Address": "str",
    "Contact": "str"
  },
  "Items": [
    {
      "Albaran": "str",
      "deliveryNote": "str",
      "Date": "str",
      "Description": "str",
      "Quantity": 0,
      "UnitPrice": "str",
      "LineTotal": "str",
      "OrderNumber": "str",
      "Weight": "str",
      "Units": "str",
      "PricePerWeight": "str",
      "CutPrice": "str",
      "Measurements": "str",
      "Status": "str",
      "Quality": "str"
    }
  ],
  "DueDates": [
    {
      "DueDate": "str",
      "Amount": "str"
    }
  ],
  "Taxes": {
    "Type": "str",
    "Amount": "str",
    "Percentage": "str"
  },
  "InvoiceTotals": {
    "Currency": "str",
    "Subtotal": "str", 
    "TaxTotal": "str",
    "GrandTotal": "str"
  }
}
```

## 📋 Reglas del Formato Sparrow

### ✅ Tipos Permitidos
- `"str"` - Campo de texto
- `0` - Campo numérico  
- `"str or null"` - Campo opcional de texto
- `0 or null` - Campo opcional numérico
- `[{...}]` - Array de objetos

### ❌ NO Permitido
- `$schema` - Metadatos de JSON Schema
- `type`, `properties`, `required` - Definiciones de schema
- `format`, `description` - Metadatos adicionales
- Tipos complejos como `"number"`, `"object"`, `"array"`

## 🚀 Queries de Ejemplo

### 1. Query Simple para Facturas
```json
{
  "invoice_number": "str",
  "date": "str",
  "supplier": "str",
  "customer": "str", 
  "total": "str"
}
```

### 2. Query con Items
```json
{
  "invoice_info": {
    "number": "str",
    "date": "str"
  },
  "items": [
    {
      "description": "str",
      "quantity": 0,
      "price": "str"
    }
  ]
}
```

### 3. Query Wildcard (Extraer Todo)
```
*
```

### 4. Query para Tablas Financieras
```json
[
  {
    "instrument_name": "str",
    "valuation": 0
  }
]
```

## 🔧 Conversión desde JSON Schema

### ❌ Formato JSON Schema (Error 418)
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "Customer name"
    }
  }
}
```

### ✅ Formato Sparrow (Funcionando)
```json
{
  "name": "str"
}
```

## 📝 Consejos de Uso

1. **Empezar simple**: Usa `*` para ver qué detecta automáticamente
2. **Probar ejemplos**: Usa los ejemplos precargados de la interfaz
3. **Incrementar complejidad**: Añade campos gradualmente
4. **Verificar tipos**: Solo usar los tipos permitidos por Sparrow

---

**Fecha**: 2025-09-26  
**Estado**: Formato validado y funcionando