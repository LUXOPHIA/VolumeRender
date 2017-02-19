//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

struct TGaussPoin
{
    float w;
    float x;
};

//------------------------------------------------------------------------------

struct TRay
{
    float3 Pos;
    float3 Vec;
};

inline TRay newTRay( const float3 Pos_, const float3 Vec_ )
{
    TRay Result;

    Result.Pos = Pos_;
    Result.Vec = Vec_;

    return Result;
}

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

static const float FLOAT_MAX = 3.402823466E+38;

SamplerState _Sampler {};

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

static int3 _VoxelsN;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

inline int3 sign3( const float3 V_ )
{
    int3 Result;

    Result.x = sign( V_.x );
    Result.y = sign( V_.y );
    Result.z = sign( V_.z );

    return Result;
}

inline float3 abs3( const float3 V_ )
{
    float3 Result;

    Result.x = abs( V_.x );
    Result.y = abs( V_.y );
    Result.z = abs( V_.z );

    return Result;
}

inline float3 floor3( const float3 V_ )
{
    float3 Result;

    Result.x = floor( V_.x );
    Result.y = floor( V_.y );
    Result.z = floor( V_.z );

    return Result;
}

inline float Pow2( const float X_ )
{
    return X_ * X_;
}

inline float3 Pow2( const float3 V_ )
{
    float3 Result;

    Result.x = Pow2( V_.x );
    Result.y = Pow2( V_.y );
    Result.z = Pow2( V_.z );

    return Result;
}

inline int MinI( const float A_, const float B_, const float C_ )
{
    if ( A_ <= B_ )
    {
        if ( A_ <= C_ ) return 0;
                   else return 2;
    }
    else
    {
        if ( B_ <= C_ ) return 1;
                   else return 2;
    }
}

inline int MinI( const float3 V_ )
{
    return MinI( V_.x, V_.y, V_.z );
}

////////////////////////////////////////////////////////////////////////////////

inline float4 GetVolumeBS1( const float3 G_ )
{
    return _Texture3D.Sample( _Sampler, ( G_ + 0.5 ) / _VoxelsN );
}

inline float4 GetVolumeBS1( const float X_, const float Y_, const float Z_ )
{
    return GetVolumeBS1( float3( X_, Y_, Z_ ) );
}

////////////////////////////////////////////////////////////////////////////////

inline float4 GetVolumeBS4( float3 G_ )
{
    int3 Gi = floor3( G_ );

    float3 Gd = G_ - Gi;
    float3 Gb = 1  - Gd;

    float3 Gd2 = Pow2( Gd );
    float3 Gb2 = Pow2( Gb );

    float3 B0 =           Gb2 *       Gb     / 6;
    float3 B1 = ( 4 - 3 * Gd2 * ( 2 - Gd ) ) / 6;
    float3 B2 = ( 4 - 3 * Gb2 * ( 2 - Gb ) ) / 6;
    float3 B3 =           Gd2 *       Gd     / 6;

    float3 W0 = B0 + B1;
    float3 W1 = B2 + B3;

    float3 I0 = Gi - 1 + B1 / W0;
    float3 I1 = Gi + 1 + B3 / W1;

    //                         BS4(G_)
    //             W0          |           W1
    //             +-----------+-----------+
    //       B0    |     B1          B2    |     B3
    //  =====#=====$=====#=====*=====#=====$=====#=====
    //       Gi-1  I0    Gi    G_    Gi+1  I1    Gi+2

    float4 C000 = GetVolumeBS1( I0.x, I0.y, I0.z );
    float4 C001 = GetVolumeBS1( I1.x, I0.y, I0.z );
    float4 C010 = GetVolumeBS1( I0.x, I1.y, I0.z );
    float4 C011 = GetVolumeBS1( I1.x, I1.y, I0.z );
    float4 C100 = GetVolumeBS1( I0.x, I0.y, I1.z );
    float4 C101 = GetVolumeBS1( I1.x, I0.y, I1.z );
    float4 C110 = GetVolumeBS1( I0.x, I1.y, I1.z );
    float4 C111 = GetVolumeBS1( I1.x, I1.y, I1.z );

    float4 C00 = W0.x * C000 + W1.x * C001;
    float4 C01 = W0.x * C010 + W1.x * C011;
    float4 C10 = W0.x * C100 + W1.x * C101;
    float4 C11 = W0.x * C110 + W1.x * C111;

    float4 C0 = W0.y * C00 + W1.y * C01;
    float4 C1 = W0.y * C10 + W1.y * C11;

    return W0.z * C0 + W1.z * C1;
}

////////////////////////////////////////////////////////////////////////////////

inline float4 GetField( const float3 P_ )
{
    float3 G = P_ / _Size * _VoxelsN - 0.5;

  //return GetVolumeBS1( G );  // Linear    Interpolation
    return GetVolumeBS4( G );  // B-Spline4 Interpolation
}

////////////////////////////////////////////////////////////////////////////////

inline float4 GetAccum1( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin S1 = { 2.0000000000000000,  0.0000000000000000 };

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    return R * ( S1.w * GetField( R_.Vec * ( R * S1.x + C ) + R_.Pos ) );
}

inline float4 GetAccum2( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin S1 = { 1.0000000000000000, -0.5773502691896257 };
    const TGaussPoin S2 = { 1.0000000000000000, -0.5773502691896257 };

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    return R * ( S1.w * GetField( R_.Vec * ( R * S1.x + C ) + R_.Pos )
               + S2.w * GetField( R_.Vec * ( R * S2.x + C ) + R_.Pos ) );
}

inline float4 GetAccum3( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin S1 = { 0.5555555555555556, -0.7745966692414834 };
    const TGaussPoin S2 = { 0.8888888888888888,  0.0000000000000000 };
    const TGaussPoin S3 = { 0.5555555555555556, +0.7745966692414834 };

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    return R * ( S1.w * GetField( R_.Vec * ( R * S1.x + C ) + R_.Pos )
               + S2.w * GetField( R_.Vec * ( R * S2.x + C ) + R_.Pos )
               + S3.w * GetField( R_.Vec * ( R * S3.x + C ) + R_.Pos ) );
}

inline float4 GetAccum4( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin S1 = { 0.3478548451374538, -0.8611363115940526 };
    const TGaussPoin S2 = { 0.6521451548625461, -0.3399810435848563 };
    const TGaussPoin S3 = { 0.6521451548625461, +0.3399810435848563 };
    const TGaussPoin S4 = { 0.3478548451374538, +0.8611363115940526 };

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    return R * ( S1.w * GetField( R_.Vec * ( R * S1.x + C ) + R_.Pos )
               + S2.w * GetField( R_.Vec * ( R * S2.x + C ) + R_.Pos )
               + S3.w * GetField( R_.Vec * ( R * S3.x + C ) + R_.Pos )
               + S4.w * GetField( R_.Vec * ( R * S4.x + C ) + R_.Pos ) );
}

inline float4 GetAccum5( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin S1 = { 0.2369268850561891, -0.9061798459386640 };
    const TGaussPoin S2 = { 0.4786286704993665, -0.5384693101056831 };
    const TGaussPoin S3 = { 0.5688888888888889,  0.0000000000000000 };
    const TGaussPoin S4 = { 0.4786286704993665, +0.5384693101056831 };
    const TGaussPoin S5 = { 0.2369268850561891, +0.9061798459386640 };

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    return R * ( S1.w * GetField( R_.Vec * ( R * S1.x + C ) + R_.Pos )
               + S2.w * GetField( R_.Vec * ( R * S2.x + C ) + R_.Pos )
               + S3.w * GetField( R_.Vec * ( R * S3.x + C ) + R_.Pos )
               + S4.w * GetField( R_.Vec * ( R * S4.x + C ) + R_.Pos )
               + S5.w * GetField( R_.Vec * ( R * S5.x + C ) + R_.Pos ) );
}

//##############################################################################

struct TSenderP
{
    float4 Scr :SV_Position;
    float4 Pos :TEXCOORD0  ;
};

struct TResultP
{
    float4 Col :SV_Target;
};

////////////////////////////////////////////////////////////////////////////////

TResultP MainP( const TSenderP _Sender )
{
    _Texture3D.GetDimensions( _VoxelsN.x, _VoxelsN.y, _VoxelsN.z );

    TResultP Result;

    float3 E = mul( _EyePos, _MatrixGL ).xyz;

    TRay R = newTRay( _Sender.Pos.xyz, normalize( _Sender.Pos.xyz - E ) );

    int3 Gv = sign3( R.Vec );

    int3 Gvs[ 3 ] = { { Gv.x,    0,    0 },
                      {    0, Gv.y,    0 },
                      {    0,    0, Gv.z } };

    float3 Sd = _Size / _VoxelsN;

    float3 Tv = Sd / abs3( R.Vec );

    float3 Tvs[ 3 ] = { { Tv.x,    0,    0 },
                        {    0, Tv.y,    0 },
                        {    0,    0, Tv.z } };

    float3 G = R.Pos / Sd - 0.5;

    int3 Gi = floor3( G );

    float3 Gd = G - Gi;

    float3 Ts;

    if ( isinf( Tv.x ) ) Ts.x = FLOAT_MAX;
                    else Ts.x = Tv.x * ( 0.5 + sign( R.Vec.x ) * ( 0.5 - Gd.x ) );

    if ( isinf( Tv.y ) ) Ts.y = FLOAT_MAX;
                    else Ts.y = Tv.y * ( 0.5 + sign( R.Vec.y ) * ( 0.5 - Gd.y ) );

    if ( isinf( Tv.z ) ) Ts.z = FLOAT_MAX;
                    else Ts.z = Tv.z * ( 0.5 + sign( R.Vec.z ) * ( 0.5 - Gd.z ) );

    Result.Col = 0;

    float T0 = 0;

    [loop]
    while ( ( -1 <= Gi.x ) && ( Gi.x <= _VoxelsN.x )
         && ( -1 <= Gi.y ) && ( Gi.y <= _VoxelsN.y )
         && ( -1 <= Gi.z ) && ( Gi.z <= _VoxelsN.z ) )
    {
        int K = MinI( Ts );

        float T1 = Ts[ K ];

        Result.Col += GetAccum3( R, T0, T1 );

        T0 = T1;

        Gi += Gvs[ K ];
        Ts += Tvs[ K ];
    }

    Result.Col /= 6;

    //--------------------------------------------------------------------------

    Result.Col.a = 0;

    Result.Col = _Opacity * Result.Col;

    return Result;
}

//##############################################################################
