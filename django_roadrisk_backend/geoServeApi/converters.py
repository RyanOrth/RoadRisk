class FloatUrlParameterConverter:
    regex = '[-]?[0-9]+\.?[0-9]+'

    def to_python(self, value):
        return float(value)

    def to_url(self, value):
        return str(value)

class BooleanUrlParameterConverter:
    regex = '(True)|(False)'

    def to_python(self, value):
        return bool(value)

    def to_url(self, value):
        return str(value)