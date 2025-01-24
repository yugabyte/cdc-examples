from google.protobuf.internal import enum_type_wrapper as _enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class Source(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = []
    UNKNOWN: _ClassVar[Source]
    LINKEDIN: _ClassVar[Source]
    TWITTER: _ClassVar[Source]
UNKNOWN: Source
LINKEDIN: Source
TWITTER: Source

class User(_message.Message):
    __slots__ = ["name", "email", "address", "birth_date", "source"]
    NAME_FIELD_NUMBER: _ClassVar[int]
    EMAIL_FIELD_NUMBER: _ClassVar[int]
    ADDRESS_FIELD_NUMBER: _ClassVar[int]
    BIRTH_DATE_FIELD_NUMBER: _ClassVar[int]
    SOURCE_FIELD_NUMBER: _ClassVar[int]
    name: str
    email: str
    address: str
    birth_date: str
    source: Source
    def __init__(self, name: _Optional[str] = ..., email: _Optional[str] = ..., address: _Optional[str] = ..., birth_date: _Optional[str] = ..., source: _Optional[_Union[Source, str]] = ...) -> None: ...
