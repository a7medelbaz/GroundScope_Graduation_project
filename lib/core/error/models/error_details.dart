class ErrorDetails {
  final String? field;
  final String? constraint;
  final Map<String, dynamic>? metadata;

  const ErrorDetails({
    this.field,
    this.constraint,
    this.metadata,
  });

  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      field: json['field'] as String?,
      constraint: json['constraint'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (field != null) 'field': field,
      if (constraint != null) 'constraint': constraint,
      if (metadata != null) 'metadata': metadata,
    };
  }
}