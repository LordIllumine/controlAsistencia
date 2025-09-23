using System;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    //public class ClassTimeSpanToStringConverter
    //{
    //}

    public class ClassTimeSpanToStringConverter : JsonConverter<TimeSpan?>
    {
        public override TimeSpan? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            if (reader.TokenType == JsonTokenType.Null)
                return null;

            var value = reader.GetString();
            return TimeSpan.TryParse(value, out var timeSpan) ? timeSpan : null;
        }

        public override void Write(Utf8JsonWriter writer, TimeSpan? value, JsonSerializerOptions options)
        {
            if (value.HasValue)
                writer.WriteStringValue(value.Value.ToString(@"hh\:mm\:ss"));
            else
                writer.WriteNullValue();
        }
    }
}
